<?php

$host= gethostname();
$ip = gethostbyname($host);

echo "Hello, world! from: {$ip}\r\n";
//echo "Hello, world!\r\n";
exit;
