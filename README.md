# NetMap
<h3>Description: </h3>
NetMap is a bash script designed to provide initial reconnaissance on a network. It utilizes ARP packet sniffing with <i><b>TcpDump</b></i> and <i><b>NetDiscover</b></i> to discover used IP addresses, determine available IP addresses, identify the network range and the router's IP address. This tool is particularly effective when connected to a network via an Ethernet cable and with the DHCP server disabled.
<h3>Usage: </h3>
<pre><code>chmod +x NetMap.sh</code></pre>
<pre><code>sudo ./NetMap.sh</code></pre>
<h3>Details: </h3>
NetMap uses <i><b>TcpDump</b></i> and <i><b>NetDiscover</b></i> to sniff ARP packets on the network. By analyzing these packets, it gathers essential information about the network infrastructure, including:
<ul>
<li>Used IP Addresses: NetMap identifies IP addresses that are currently in use on the network.</li>
<li>Available IP Addresses: Based on the discovered information, NetMap determines which IP addresses within the network range are available for use.</li>
<li>Network Range: NetMap calculates the network range, providing insight into the scope of the network.</li>
<li>Router IP Address: By analyzing ARP packets, NetMap identifies the IP address of the router, a critical component of the network infrastructure.</li>
</ul>

![second](https://github.com/IBarrous/NetMap/assets/126162952/5346b4ae-14de-4818-bd3f-2eabcb9688ec)

![first](https://github.com/IBarrous/NetMap/assets/126162952/c8276b3d-f71c-444e-a68b-f03292612858)

<h3>Note:</h3>
NetMap must be executed with elevated privileges, as both <i><b>TcpDump</b></i> and <i><b>NetDiscover</b></i> require administrative access to capture network traffic and perform network discovery.
