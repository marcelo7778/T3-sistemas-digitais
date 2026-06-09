module scratchpad_ram (
    input  logic       clk,      // Operará a 100 MHz junto com o Coletor
    input  logic [7:0] data_i,   // Dado vindo do Coletor
    input  logic [7:0] addr,     // Endereço incremental vindo do Coletor
    input  logic       we,       // Write Enable vindo do Coletor
    output logic [7:0] data_o    // Saída exposta para validação do Testbench
);
    // Memória de 256 posições de 8 bits (2^8 x 8)
    logic [7:0] memory [256];

    always_ff @(posedge clk) begin
        if (we) begin
            memory[addr] <= data_i; // Escrita síncrona
        end
        data_o <= memory[addr];     // Leitura contínua/síncrona
    end
endmodule