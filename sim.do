if {[file isdirectory work]} {vdel -all -lib work}

vlib work
vmap work work

vlog -work work Emulador_sensor.sv
vlog -work work Master_spi.sv
vlog -work work Scratchped_ram_Teste.sv
vlog -work work Top.sv
vlog -work work tb_Top.sv

vsim -voptargs=+acc work.tb_Top

quietly set StdArithNoWarnings 1
quietly set StdVitalGlitchNoWarnings 1

add wave -r /*


run 1000ns

wave zoom full
