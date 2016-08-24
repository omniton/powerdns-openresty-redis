# Installing 

1. Prepare host server environment (ubuntu version script: install/ubuntu-prepare-environment.sh)
2. Download & extract latest openresty tarball (http://openresty.org/en/download.html)
3. Copy installation script into extracted openresty folder and run.
4. Copy nginx/powerdns.conf to /etc/nginx/sites-enabled folder (uncomment set $redis_host and set $redis_port)
5. Copy nginx/lookup.lua to /usr/local/openresty/nginx folder
6. Restart nginx: ```/etc/init.d/nginx```
7. Install redis server: ```apt install redis-server```
8. Install PowerDNS server: ```apt install pdns-server pdns-backend-remote```
9. Copy powerdns/pdns.local.conf to /etc/powerdns/pdns.d folder
10. Restart pdns server: ```/etc/init.d/pdns restart```
11. Add into redis soa domain zone record:
```rpush example.com./SOA "{\"qtype\":\"SOA\", \"qname\":\"example.com\", \"content\":\"dns1.icann.org. hostmaster.icann.org. 2012081600 7200 3600 1209600 3600\", \"ttl\": 3600}"```
12. Add some test domain zone record:
```rpush test.example.com./A "{\"qtype\":\"A\", \"qname\":\"test.example.com\", \"content\":\"1.2.3.4\", \"ttl\": 3600}"```
13. Check dns resolving: ```dig a test.example.com @localhost```
If everything works you will see:
```
; <<>> DiG 9.10.3-P4-Ubuntu <<>> a test.example.com @localhost
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18388
;; flags: qr rd; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1680
;; QUESTION SECTION:
;test.example.com.		IN	A

;; AUTHORITY SECTION:
test.example.com.	3600	IN	A	1.2.3.4

;; Query time: 63 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; MSG SIZE  rcvd: 61
```
