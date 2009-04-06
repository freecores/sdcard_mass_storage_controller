#!/usr/bin/perl

@data = ();

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
$i =0;
while($i <= $#data) {
    printf ("%2.2x%2.2x%2.2x%2.2x\n", $data[$i], $data[$i+1], $data[$i+2], $data[$i+3]);
    $i+=4;
}
