..
..
.. Licensed under the Apache License, Version 2.0 (the "License");
.. you may not use this file except in compliance with the License.
.. You may obtain a copy of the License at
..
..     http://www.apache.org/licenses/LICENSE-2.0
..
.. Unless required by applicable law or agreed to in writing, software
.. distributed under the License is distributed on an "AS IS" BASIS,
.. WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
.. See the License for the specific language governing permissions and
.. limitations under the License.
..

.. _to-api-v2-cdns-name-configs-monitoring:

************************************
``cdns/{{name}}/configs/monitoring``
************************************

.. seealso:: :ref:`health-proto`

``GET``
=======
Retrieves information concerning the monitoring configuration for a specific CDN.

:Auth. Required: Yes
:Roles Required: None
:Response Type:  Object

Request Structure
-----------------
.. table:: Request Path Parameters

	+------+------------------------------------------------------------------------+
	| Name | Description                                                            |
	+======+========================================================================+
	| name | The name of the CDN for which monitoring configuration will be fetched |
	+------+------------------------------------------------------------------------+

Response Structure
------------------
:cacheGroups: An array of objects representing each of the :term:`Cache Groups` being monitored within this CDN

	:coordinates: An object representing the geographic location of this :term:`Cache Group`

		:latitude:  This :ref:`Cache Group's latitude <cache-group-latitude>` as a floating-point number
		:longitude: This :ref:`Cache Group's longitude <cache-group-longitude>` as a floating-point number

	:name: A string that is this :ref:`Cache Group's name <cache-group-name>`

:config: A collection of parameters used to configure the monitoring behaviour of Traffic Monitor

	:health.polling.interval:     An interval in milliseconds on which to poll for cache statistics
	:heartbeat.polling.interval:  An interval in milliseconds on which to poll for health statistics. If missing, defaults to ``health.polling.interval``.
	:tm.polling.interval:         The interval at which to poll for configuration updates

:deliveryServices: An array of objects representing each :term:`Delivery Service` provided by this CDN

	:status:             The :term:`Delivery Service`'s status
	:totalKbpsThreshold: A threshold rate of data transfer this :term:`Delivery Service` is configured to handle, in Kilobits per second
	:totalTpsThreshold:  A threshold amount of transactions per second that this :term:`Delivery Service` is configured to handle
	:xmlId:              A string that is the :ref:`Delivery Service's XMLID <ds-xmlid>`

:profiles: An array of the :term:`Profiles` in use by the :term:`cache servers` and :term:`Delivery Services` belonging to this CDN

	:name:       A string that is the :ref:`Profile's Name <profile-name>`
	:parameters: An array of the :term:`Parameters` in this :term:`Profile` that relate to monitoring configuration. This can be ``null`` if the servers using this :term:`Profile` cannot be monitored (e.g. Traffic Routers)

		:health.connection.timeout:                 A timeout value, in milliseconds, to wait before giving up on a health check request
		:health.polling.url:                        A URL to request for polling health. Substitutions can be made in a shell-like syntax using the properties of an object from the ``"trafficServers"`` array
		:health.threshold.availableBandwidthInKbps: The total amount of bandwidth that servers using this profile are allowed, in Kilobits per second. This is a string and using comparison operators to specify ranges, e.g. ">10" means "more than 10 kbps"
		:health.threshold.loadavg:                  The UNIX loadavg at which the server should be marked "unhealthy"

			.. seealso:: :manpage:`uptime(1)`

		:health.threshold.queryTime: The highest allowed length of time for completing health queries (after connection has been established) in milliseconds
		:history.count:              The number of past events to store; once this number is reached, the oldest event will be forgotten before a new one can be added

	:type: A string that names the :ref:`Profile's Type <profile-type>`

:trafficMonitors: An array of objects representing each Traffic Monitor that monitors this CDN (this is used by Traffic Monitor's "peer polling" function)

	:fqdn:     An :abbr:`FQDN (Fully Qualified Domain Name)` that resolves to the IPv4 (and/or IPv6) address of the server running this Traffic Monitor instance
	:hostname: The hostname of the server running this Traffic Monitor instance
	:ip6:      The IPv6 address of this Traffic Monitor - when applicable
	:ip:       The IPv4 address of this Traffic Monitor
	:port:     The port on which this Traffic Monitor listens for incoming connections
	:profile:  A string that is the :ref:`profile-name` of the :term:`Profile` assigned to this Traffic Monitor
	:status:   The status of the server running this Traffic Monitor instance

:trafficServers: An array of objects that represent the :term:`cache servers` being monitored within this CDN

	:cacheGroup:    The :term:`Cache Group` to which this :term:`cache server` belongs
	:fqdn:          An :abbr:`FQDN (Fully Qualified Domain Name)` that resolves to the :term:`cache server`'s IPv4 (or IPv6) address
	:hashId:        The (short) hostname for the :term:`cache server` - named "hashId" for legacy reasons
	:hostName:      The (short) hostname of the :term:`cache server`
	:interfacename: The name of the network interface device being used by the :term:`cache server`'s HTTP proxy
	:ip6:           The :term:`cache server`'s IPv6 address - when applicable
	:ip:            The :term:`cache server`'s IPv4 address
	:port:          The port on which the :term:`cache server` listens for incoming connections
	:profile:       A string that is the :ref:`profile-name` of the :term:`Profile` assigned to this :term:`cache server`
	:status:        The status of the :term:`cache server`
	:type:          A string that names the :term:`Type` of the :term:`cache server` - should (ideally) be either ``EDGE`` or ``MID``

.. code-block:: http
	:caption: Response Example

	HTTP/1.1 200 OK
	Access-Control-Allow-Credentials: true
	Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept, Set-Cookie, Cookie
	Access-Control-Allow-Methods: POST,GET,OPTIONS,PUT,DELETE
	Access-Control-Allow-Origin: *
	Content-Type: application/json
	Set-Cookie: mojolicious=...; Path=/; Expires=Mon, 18 Nov 2019 17:40:54 GMT; Max-Age=3600; HttpOnly
	Whole-Content-Sha512: uLR+tRoqR8SYO38j3DV9wQ+IkJ7Kf+MCoFkcWZtsgbpLJ+0S6f+IiI8laNVeDgrM/P23MAQ6BSepm+EJRl1AXQ==
	X-Server-Name: traffic_ops_golang/
	Date: Wed, 14 Nov 2018 21:09:31 GMT
	Transfer-Encoding: chunked

	{ "response": {
		"trafficServers": [
			{
				"profile": "ATS_EDGE_TIER_CACHE",
				"status": "REPORTED",
				"ip": "172.16.239.100",
				"ip6": "fc01:9400:1000:8::100",
				"port": 80,
				"cachegroup": "CDN_in_a_Box_Edge",
				"hostname": "edge",
				"fqdn": "edge.infra.ciab.test",
				"interfacename": "eth0",
				"type": "EDGE",
				"hashid": "edge"
			},
			{
				"profile": "ATS_MID_TIER_CACHE",
				"status": "REPORTED",
				"ip": "172.16.239.120",
				"ip6": "fc01:9400:1000:8::120",
				"port": 80,
				"cachegroup": "CDN_in_a_Box_Mid",
				"hostname": "mid",
				"fqdn": "mid.infra.ciab.test",
				"interfacename": "eth0",
				"type": "MID",
				"hashid": "mid"
			}
		],
		"trafficMonitors": [
			{
				"profile": "RASCAL-Traffic_Monitor",
				"status": "ONLINE",
				"ip": "172.16.239.40",
				"ip6": "fc01:9400:1000:8::40",
				"port": 80,
				"cachegroup": "CDN_in_a_Box_Edge",
				"hostname": "trafficmonitor",
				"fqdn": "trafficmonitor.infra.ciab.test"
			}
		],
		"cacheGroups": [
			{
				"name": "CDN_in_a_Box_Mid",
				"coordinates": {
					"latitude": 38.897663,
					"longitude": -77.036574
				}
			},
			{
				"name": "CDN_in_a_Box_Edge",
				"coordinates": {
					"latitude": 38.897663,
					"longitude": -77.036574
				}
			}
		],
		"profiles": [
			{
				"name": "CCR_CIAB",
				"type": "CCR",
				"parameters": null
			},
			{
				"name": "ATS_EDGE_TIER_CACHE",
				"type": "EDGE",
				"parameters": {
					"health.connection.timeout": 2000,
					"health.polling.url": "http://${hostname}/_astats?application=&inf.name=${interface_name}",
					"health.threshold.availableBandwidthInKbps": ">1750000",
					"health.threshold.loadavg": "25.0",
					"health.threshold.queryTime": 1000,
					"history.count": 30
				}
			},
			{
				"name": "ATS_MID_TIER_CACHE",
				"type": "MID",
				"parameters": {
					"health.connection.timeout": 2000,
					"health.polling.url": "http://${hostname}/_astats?application=&inf.name=${interface_name}",
					"health.threshold.availableBandwidthInKbps": ">1750000",
					"health.threshold.loadavg": "25.0",
					"health.threshold.queryTime": 1000,
					"history.count": 30
				}
			}
		],
		"deliveryServices": [],
		"config": {
			"health.polling.interval": 6000,
			"heartbeat.polling.interval": 3000,
			"peers.polling.interval": 3000,
			"tm.polling.interval": 2000
		}
	}}
