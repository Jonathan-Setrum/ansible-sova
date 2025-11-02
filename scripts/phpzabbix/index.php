<?php
/*
$ipAddress = $_SERVER['REMOTE_ADDR'];
if (array_key_exists('HTTP_X_FORWARDED_FOR', $_SERVER)) {
    $ipAddress = array_pop(explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']));
}
if ($ipAddress != '') {
	die('Please Do From Whitelisted IP');
}
*/

if (isset($_GET['ym']) && isset($_GET['ip'])) {
	$now = strtotime($_GET['ym'].'-01 00:00:00');
	$ip = $_GET['ip'];
}
else {
	//$now = time();
	//print_r($_SERVER);
	die('Usage: Need to specify Year and Month ('.$_SERVER['SCRIPT_URI'].'?ym=YYYY-MM&ip=192.168.1.1)');
}
// load ZabbixApi
require_once 'lib/ZabbixApi.class.php';
use ZabbixApi\ZabbixApi;
try {
	$the_host = $ip; //"103.250.202.14";
    // connect to Zabbix API
    $api = new ZabbixApi('https://zabbix02.sova.sg/zabbix/api_jsonrpc.php', 'aaron', 'onigiri/0517');
// var_dump($api);

	// get host
	$my_host_id = null;
    $api->setDefaultParams(array(
        'output' => 'extend',
		'filter' => array(
            "host" => array(
				$the_host,
                //"Zabbix server", 
				//"219.94.218.158",
				//"103.250.200.11",
            )
        )
    ));
	$myhosts = $api->hostGet();
    foreach($myhosts as $host1) {
		echo "HOST: ($the_host) {$host1->hostid} {$host1->host}<br/>";
		$my_host_id = $host1->hostid;
	}
	//echo $my_host_id.'<hr/>';
	if ($my_host_id == null) die('Host IP not Found');

	$sday = date('Y-m-01', $now);
	$eday = date('Y-m-t', $now);
	$ym = date('Ym', $now);
	echo "Date Range: $sday to $eday<br/>";
	$t_start = strtotime($sday.' 00:00:00');
	$t_end = strtotime($eday.' 23:59:59');
	echo "UTC Range: $t_start $t_end<br/>";

	$fprefix = 'zabbix-'.$the_host.'-'.$ym;
	
	// get items of a host
	$item_a = array(
		"Outgoing network traffic" => array( 'f'=>'outgoing', 'id'=>'' ),
		"Incoming network traffic" => array( 'f'=>'incoming', 'id'=>'' ),
	);
	if ($item_a) foreach ($item_a as $k=>$v) {
		$api->setDefaultParams(array(
			"output" => "extend",
			'hostids' => array( $my_host_id ),
			"search" => array(
				"name" => $k
			),
			"sortfield" => "name",
		));
		$items = $api->itemGet();
		foreach($items as $item1) {
			//var_dump($item1); echo '<hr/>';
			echo "ITEM: ($k) {$item1->itemid} {$item1->name}<br/>";
			$item_a[$k]['id'] = $item1->itemid;
		}
	}

	$zip = new ZipArchive();
	$zip->open("$fprefix.zip", ZipArchive::CREATE);
	$fn_a = array();

	if ($item_a) foreach ($item_a as $k=>$v) {
		if ($item_a[$k]['id']) {
			$fn1 = $fprefix.'-'.$item_a[$k]['f'].'.csv';
echo "$fn1<br/>";
			$fh1 = fopen($fn1,"wt");
			$api->setDefaultParams(array(
				"output" => "extend",
				'history' => 3,
				'hostids' => array( $my_host_id ),
				'itemids' => array( $item_a[$k]['id'] ),
				//'hostids' => $my_host_id,
				//'itemids' => $my_item_id,
				'time_from' => $t_start, // $now - 28800,
				'time_till' => $t_end, // $now,
				//"limit" => 100,
				"sortfield" => "clock",
				//"sortorder" => "ASC",
			));
			$hists = $api->historyGet();
//var_dump($hists);
			$cnt = 0;
			$sum = 0;
			$avg = 0;
			fwrite($fh1, "DateTime\tValue (Bytes Per Second\r\n");
			if ($hists) foreach($hists as $h1) {
				$cnt++;
				$sum += $h1->value;
				// var_dump($h1); echo "<hr/>";
				//echo date('Y-m-d H:i:s',$h1->clock).",{$h1->value}<br/>";
				fwrite($fh1, date('Y-m-d H:i:s',$h1->clock)."\t".$h1->value."\r\n");
			}
			if ($cnt > 0) $avg = floatval($sum) / floatval($cnt);
			fwrite($fh1, "Number Of Readings\t$cnt\r\n");
			fwrite($fh1, "Average\t$avg\r\n");
			fclose($fh1);
			$zip->addFile($fn1, $fn1);
			$fn_a[] = $fn1;
		}
	}
	
/*
	$my_item_id = null;
	$api->setDefaultParams(array(
		"output" => "extend",
        'hostids' => array( $my_host_id ),
        "search" => array(
            "name" => "Outgoing network traffic"
			//Does Not Work, I think is AND condition :) "name" => array("Incoming network traffic", "Outgoing network traffic")
			//"name" => "network traffic"
        ),
		"sortfield" => "name",
	));
	$items = $api->itemGet();
    foreach($items as $item1) {
		//var_dump($item1); echo '<hr/>';
		echo "{$item1->itemid} {$item1->name}<hr/>";
		$my_item_id = $item1->itemid;
	}
	echo "$my_host_id $my_item_id<hr/>";

	// get history
	$fn1 = $fprefix.'-'.'outgoing'.'.csv';
	$fh1 = fopen($fn1,"wt");
	$api->setDefaultParams(array(
		"output" => "extend",
        'history' => 3,
        'hostids' => array( $my_host_id ),
        'itemids' => array( $my_item_id ),
        //'hostids' => $my_host_id,
        //'itemids' => $my_item_id,
        'time_from' => $t_start, // $now - 28800,
        'time_till' => $t_end, // $now,
		//"limit" => 100,
        "sortfield" => "clock",
        //"sortorder" => "ASC",
	));
	$hists = $api->historyGet();
    foreach($hists as $h1) {
		// var_dump($h1); echo "<hr/>";
		//echo date('Y-m-d H:i:s',$h1->clock).",{$h1->value}<br/>";
		fwrite($fh1, date('Y-m-d H:i:s',$h1->clock)."\t".$h1->value."\r\n");
	}
	fclose($fh1);
*/

	$zip->close(); // zip it up
	if ($fn_a) foreach ($fn_a as $fn_1) unlink($fn_1); // delete files

	echo 'DONE. Download here '."<a href='$fprefix.zip'>ZIP File</a>";
}
catch(Exception $e) {
    // Exception in ZabbixApi catched
    echo $e->getMessage();
}
?>