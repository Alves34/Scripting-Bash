#!/bin/sh
## SCRIPT de IPTABLES - Protección Básica con DROP por defecto
## Este script establece una política por defecto de DROP en todas las cadenas, y luego abre explícitamente ciertos puertos y conexiones específicas.

# Limpiar todas las reglas y contadores de las tablas
iptables -F  # Borra todas las reglas de la cadena de filtrado (FILTER)
iptables -X  # Borra todas las cadenas personalizadas
iptables -Z  # Reinicia los contadores de paquetes y bytes a cero
iptables -t nat -F  # Borra todas las reglas de la tabla NAT (Network Address Translation)

# Establecer políticas por defecto: DROP
iptables -P INPUT DROP  # Establece la política por defecto para los paquetes entrantes como DROP
iptables -P OUTPUT DROP  # Establece la política por defecto para los paquetes salientes como DROP
iptables -P FORWARD DROP  # Establece la política por defecto para los paquetes reenviados como DROP

# Permitir tráfico local (localhost)
iptables -A INPUT -i lo -j ACCEPT  # Acepta todo el tráfico de entrada en la interfaz de loopback
iptables -A OUTPUT -o lo -j ACCEPT  # Acepta todo el tráfico de salida en la interfaz de loopback

# Permitir conexiones establecidas y relacionadas
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT  # Acepta paquetes relacionados con conexiones ya establecidas

# Permitir tráfico específico para ciertas direcciones IP y puertos
iptables -A INPUT -s 192.168.0.10 -j ACCEPT  # Permite todo el tráfico entrante desde la dirección IP específica en la red 192.168.0.0
iptables -A OUTPUT -d 192.168.0.20 -j ACCEPT  # Permite todo el tráfico saliente hacia la dirección IP específica en la red 192.168.0.0

iptables -A INPUT -s 192.168.0.30 -p tcp --dport 3306 -j ACCEPT  # Permite el tráfico entrante de MySQL desde la dirección IP específica en el puerto 3306
iptables -A OUTPUT -d 192.168.0.40 -p tcp --sport 3306 -j ACCEPT  # Permite el tráfico saliente de MySQL hacia la dirección IP específica en el puerto 3306

iptables -A INPUT -s 192.168.0.50 -p tcp -m multiport --dports 20:21 -j ACCEPT  # Permite el tráfico entrante de FTP desde la dirección IP específica en los puertos 20 y 21
iptables -A OUTPUT -d 192.168.0.60 -p tcp -m multiport --sports 20:21 -j ACCEPT  # Permite el tráfico saliente de FTP hacia la dirección IP específica en los puertos 20 y 21

# Permitir conexiones HTTP y HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT  # Permite el tráfico HTTP entrante
iptables -A INPUT -p tcp --dport 443 -j ACCEPT  # Permite el tráfico HTTPS entrante

iptables -A OUTPUT -p tcp --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT  # Permite el tráfico HTTP saliente relacionado o establecido
iptables -A OUTPUT -p tcp --sport 443 -m state --state RELATED,ESTABLISHED -j ACCEPT  # Permite el tráfico HTTPS saliente relacionado o establecido

# Permitir consultas DNS y sincronización de hora
iptables -A INPUT -p udp --sport 53 -j ACCEPT  # Permite el tráfico UDP de consulta DNS entrante
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT  # Permite el tráfico UDP de respuesta DNS saliente

iptables -A INPUT -p udp --dport 123 -j ACCEPT  # Permite el tráfico UDP de sincronización de hora entrante
iptables -A OUTPUT -p udp --sport 123 -j ACCEPT  # Permite el tráfico UDP de sincronización de hora saliente

# Proteger puertos reservados y conocidos
iptables -A INPUT -p tcp --dport 1:1024 -j DROP  # Bloquea puertos TCP reservados y conocidos entrantes
iptables -A INPUT -p udp --dport 1:1024 -j DROP  # Bloquea puertos UDP reservados y conocidos entrantes

echo " OK. Verifique las reglas aplicadas con: iptables -L -n"
