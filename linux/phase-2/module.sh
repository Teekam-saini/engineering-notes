#!/bin/bash
read -p "enter module name: " module_name
read -p "enter input ports: " input_ports
read -p "enter output ports: " output_ports

cat <<EOF
mdoule template
==============
module $module_name(
input wire $input_ports ,
output wire $output_ports );

#write your logic here

endmodule 

EOF

