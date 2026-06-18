module Top (
    input logic clk_100M, // Clock do Coletor de Dados (Master) e RAM
    input logic clk_15M,  // Clock exclusivo do Emulador de Sensor 1
    input logic clk_40M,  // Clock exclusivo do Emulador de Sensor 2
    input logic clk_50M,  // Clock exclusivo do Emulador de Sensor 3
    input logic clk_25M,  // Clock exclusivo do Emulador de Sensor 4
    
    input logic reset,    // reset ativo em baixo

    // Interface de Comando
    input  logic       start,  // TB inicia uma varredura
    input  logic [1:0] reg_id, // TB escolhe qual ID de sensor ler
    output logic       ready,  // Top avisa ao TB que está pronto/ocioso

    // Interface de Verificação
    output logic [7:0] ram_data_o // Permite ao TB ler o que foi salvo na RAM
);

    logic       sclk_net;
    logic       mosi_net;
    logic       miso_mux; // Saída do Multiplexador que vai para o Master
    logic [3:0] se_net;   // Vetor de Slave Enable (se[0] a se[3])

    // miso de cada sensor
    logic miso_s1, miso_s2, miso_s3, miso_s4;

    logic [7:0] ram_data_i_net;
    logic [7:0] ram_addr_net;
    logic       ram_we_net;


    // sensor 1 - 15 MHz
    sensor #(
        .SENSOR_ID(0), // ID 2'b00
        .REG_COUNT(4),
        .REG_WIDTH(8)
    ) Sensor1 (
        .clock(clk_15M),
        .reset(reset),
        .se(se_net[0]),
        .miso(miso_s1),
        .mosi(mosi_net),
        .sclk(sclk_net)
    );

    // sensor 2 - 40 MHz
    sensor #(
        .SENSOR_ID(1), // ID 2'b01
        .REG_COUNT(4),
        .REG_WIDTH(8)
    ) Sensor2 (
        .clock(clk_40M),
        .reset(reset),
        .se(se_net[1]),
        .miso(miso_s2),
        .mosi(mosi_net),
        .sclk(sclk_net)
    );

    // sensor 3 - 50 MHz
    sensor #(
        .SENSOR_ID(2), // ID 2'b10
        .REG_COUNT(4),
        .REG_WIDTH(8)
    ) Sensor3 (
        .clock(clk_50M),
        .reset(reset),
        .se(se_net[2]),
        .miso(miso_s3),
        .mosi(mosi_net),
        .sclk(sclk_net)
    );

    // sensor 4 - 25 MHz
    sensor #(
        .SENSOR_ID(3), // ID 2'b11
        .REG_COUNT(4),
        .REG_WIDTH(8)
    ) Sensor4 (
        .clock(clk_25M),
        .reset(reset),
        .se(se_net[3]),
        .miso(miso_s4),
        .mosi(mosi_net),
        .sclk(sclk_net)
    );


    // MULTIPLEXADOR DAS LINHAS MISO 
    // Isola e conecta o pino MISO correto ao Master com base no chip-select ativo.
    always_comb begin
        case (se_net)
            4'b0001: miso_mux = miso_s1;
            4'b0010: miso_mux = miso_s2;
            4'b0100: miso_mux = miso_s3;
            4'b1000: miso_mux = miso_s4;
            default: miso_mux = 1'b0; // Evita estados indefinidos/alta impedância
        endcase
    end


    Master_Spi spi_master (
        .clk(clk_100M),
        .reset(reset),
        
        // Conexões direcionadas para a interface de controle externa
        .start(start),
        .reg_id(reg_id),
        .ready(ready),
        
        // Conexões com o barramento SPI
        .sclk(sclk_net),
        .mosi(mosi_net),
        .miso(miso_mux), // Recebe a linha selecionada pelo multiplexador
        .se(se_net),
        
        // Conexões direcionadas à Scratchpad RAM
        .ram_data_i(ram_data_i_net),
        .ram_addr(ram_addr_net),
        .ram_we(ram_we_net)
    );

    scratchpad_ram ram_block (
        .clk(clk_100M),
        .data_i(ram_data_i_net),
        .addr(ram_addr_net),
        .we(ram_we_net),
        .data_o(ram_data_o)
    );

endmodule
