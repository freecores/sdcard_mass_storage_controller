#!/usr/bin/perl

@data = ();

# Intel HEX format interpreter
while(<>) {
  if (m/\:([A-F0-9]{2})([A-F0-9]{4})([A-F0-9]{2})([A-F0-9]+)([A-F0-9]{2})/) {
    $vec = $4;
    $len = hex $1;
    $rec_type = $3;
    $byte_addr = (hex $2);
    if ($len > 0) {
      for (my($i)=0; $i < $len*2; $i+=2) {
        $data[$byte_addr++] = hex substr($vec, $i, 2);
      }
    }
  }
}

use Shell;
#Execute a command which parses the System.map file and determines the address
#of the boot code, and thus the total size of it that will be loaded from the
#SPI flash.
$code_size_cmd = "tail -n 1 System.map | sed 's/:.*//g' | sed 's/^[ ]*//'";
$code_size = hex(qx{ $code_size_cmd });

#The following doesn't want to play for some reason; unrolling...
#for(my($j)=0; $j < 4; $j++){
#    $size_bytes[$j] = $code_size & (hex(ff)<<($j*2)) / (hex(1)<<($j*2));
#}

$size_bytes[0] = $code_size & hex(ff) / hex(1);
$size_bytes[1] = ($code_size & hex(ff00)) / hex(100);
$size_bytes[2] = ($code_size & hex(ff0000)) / hex(10000);
$size_bytes[3] = ($code_size & hex(ff000000)) / hex(1000000);
printf("//SPI Flash ROM data, byte per line. First word is length of ROM\n");
for(my($j)=0; $j < 4; $j++){
    printf("%2.2x\n",$size_bytes[3-$j]);
}
$i =4;
while($i <= $#data) {
    printf ("%2.2x\n", $data[$i]);
    $i+=1;
}
