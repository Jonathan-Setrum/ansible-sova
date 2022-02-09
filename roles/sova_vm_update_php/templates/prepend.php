<?php
/* BEGIN VARNISH HTTP Purge Settings */
define('VHP_VARNISH_IP','127.0.0.1');
/* END VARNISH HTTP Purge Settings */

/* BEGIN REAL-IP Settings */
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO'])
		    && $_SERVER['HTTP_X_FORWARDED_PROTO'] === "https") {
			  $_SERVER['HTTPS'] = 'on';
}
/* END REAL-IP Settings */
