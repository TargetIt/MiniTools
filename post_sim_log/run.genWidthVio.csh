echo $1

grep -A 1 violation $1 > $1.violation
grep -B 1 '$width' $1.violation > $1.violation.width

rm -rf $1.violation

#sed -i '/pipew_.*m1_reg/,+2d'        $1.violation.width
#sed -i '/desbuf_tst/,+2d'            $1.violation.width
#sed -i '/descust_sigdet_m1_reg/,+2d' $1.violation.width
#sed -i '/sdoc_fcc_status_reg/,+2d'   $1.violation.width
#sed -i '/serdes_top_i1$/,+2d'        $1.violation.width
