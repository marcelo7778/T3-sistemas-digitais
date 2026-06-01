module sensor #(
    parameter SENSOR_ID,
    parameter REG_COUNT,
    parameter REG_WIDTH,
)(
    input  logic clock,
    input  logic reset,

    input  logic[$clog2(REG_COUNT)] se,
    output logic miso,
    input  logic mosi,
    output logic sclk
);

// lista de registradores
logic[REG_WIDTH-1:0][REG_COUNT-1:0] regs;

// temp register
logic[REG_WIDTH-1:0] temp_reg;

// clock de saída do sensor,
// para sincronizar com o coletor
assign sclk = clock;

// state machine - SPI
enum state_t = { IDLE, SETUP, RECEIVE, SEND, CLEANUP};

state_t EA;  // estado atual
state_t PE;  // próximo estado

// verifica o estado atual e decide qual 
// será o próximo estado
always @(posedge clk, posedge reset) begin
    if(reset == 0) begin
        // case (estado) ...
    end else begin 
        PE <= IDLE;
    end

    EA <= PE; // o estado atual é o próximo
              // estado do ciclo anterior
end   

// lê/escreve dos registradores internos 
// de acordo com o estado atual
always @(posedge clk, posedge reset) begin
    case (EA) begin

    end 
end   

// atualiza a leitura do sensor periodicamente
always @(posedge clk, posedge reset) begin   
    if(reset == 0) begin
        genvar i;
        generate
            for (i = 0; i < REG_COUNT; i++) begin
                regs[i] = $random(SENSOR_ID);
            end
        endgenerate
    end else begin
        genvar i;
        generate
            for (i = 0; i < REG_COUNT; i++) begin
                regs[i] = 0;
            end
        endgenerate
    end
end

endmodule 