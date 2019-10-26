<?php
  date_default_timezone_set('America/New_York');
  $timestamp = getenv('POPCLIP_TEXT');
  //echo gmdate("Y-m-d\TH:i:s\Z", $timestamp);
  echo date("D M j G:i:s T Y", $timestamp);
?>

