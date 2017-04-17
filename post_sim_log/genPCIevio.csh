echo $1

grep -A 1 violation $1 > $1.violation
grep -B 1 "setup\|hold(" $1.violation > $1.violation.setuphold
grep -B 1 "pcie_intg" $1.violation.setuphold > $1.violation.setuphold.pcie_intg

rm -rf $1.violation
rm -rf $1.violation.setuphold

sed -i '/pipew_.*m1_reg/,+2d'        $1.violation.setuphold.pcie_intg
sed -i '/desbuf_tst/,+2d'            $1.violation.setuphold.pcie_intg
sed -i '/descust_sigdet_m1_reg/,+2d' $1.violation.setuphold.pcie_intg
sed -i '/sdoc_fcc_status_reg/,+2d'   $1.violation.setuphold.pcie_intg
sed -i '/serdes_top_i1$/,+2d'        $1.violation.setuphold.pcie_intg
