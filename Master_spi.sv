module Master_Spi (
    input  logic       Misso,
    input  logic       Mosi,
    input  logic [1:0] Se, 
    input  logic       Sclk,
    input  logic       clok,
    input  logic       reset,

    output logic [7:0] data_in,  
    output logic [7:0] data_out, 
    output logic       wo,       
    output logic [7:0] addr 
);

    logic [2:0] sclk_sync;
    logic       sclk_rise;

    always_ff @(posedge clok or posedge reset) begin
        if (reset) begin
            sclk_sync <= 3'b000;
        end else begin
            sclk_sync <= {sclk_sync[1:0], Sclk};
        end
    end



    assign sclk_rise = (sclk_sync[2:1] == 2'b01);

    logic [7:0] shift_mosi;
    logic [7:0] shift_miso;
    logic [3:0] bit_cnt;

    always_ff @(posedge clok or posedge reset) begin
        if (reset) begin
            shift_mosi <= 8'd0;
            shift_miso <= 8'd0;
            bit_cnt    <= 4'd0;
            wo         <= 1'b0;
            addr       <= 8'd0;
            data_in    <= 8'd0;
            data_out   <= 8'd0;
        end else begin
            wo <= 1'b0;
            if (~Se[0] || ~Se[1]) begin
                
                // Realiza a captura no instante da borda de subida do SCLK
                if (sclk_rise) begin
                    // Desloca o bit mais recente para dentro dos registradores
                    shift_mosi <= {shift_mosi[6:0], Mosi};
                    shift_miso <= {shift_miso[6:0], Misso};
                    bit_cnt    <= bit_cnt + 1'b1;

                    // Quando completar 8 bits, joga para a saída e avisa a memória
                    if (bit_cnt == 4'd7) begin
                        data_out <= {shift_mosi[6:0], Mosi};
                        data_in  <= {shift_miso[6:0], Misso};
                        wo       <= 1'b1;        // Dispara o pulso de escrita (wb)
                        addr     <= addr + 1'b1; // Incrementa o endereço para o próximo byte
                        bit_cnt  <= 4'd0;        // Reseta o contador de bits
                    end
                end
            end else begin
                bit_cnt <= 4'd0;
            end
        end
    end

endmodule