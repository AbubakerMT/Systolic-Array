module top #(parameter max_n=10, max_m=10, max_p=10) (
    input clk,
    input reset,
    input start,
    input signed [26:0] din1, // For n, m, p, and Matrix A elements
    input signed [26:0] din2, // For Matrix B elements
    output reg signed [26:0] dout, // Output data
    output reg strobe // High when dout is valid
);

    // State Encoding
    reg [3:0] state;
    localparam S1_IDLE     = 4'd0;
    localparam S2_READ_N   = 4'd1;
    localparam S3_READ_M   = 4'd2;
    localparam S4_READ_P   = 4'd3;
    localparam S5_READ_A   = 4'd4;
    localparam S6_READ_B   = 4'd5;
    localparam S7_COMPUTE  = 4'd6;
    localparam S8_OUTPUT   = 4'd7;

    // Parameters and Counters
    reg [3:0] n, m, p; // Dimensions of the matrices (up to max_n, max_m, max_p)
    reg [15:0] count_a, count_b, count_c; // Counters for reading/writing data
    reg [15:0] idx_a, idx_b, idx_c; // Indexes for flattened arrays

    // Flattened Matrices
    reg signed [26:0] A_flat [0:(max_n*max_m)-1];
    reg signed [26:0] B_flat [0:(max_m*max_p)-1];
    reg signed [47:0] C_flat [0:(max_n*max_p)-1]; // Wider to prevent overflow during accumulation

    // Indices for computation
    reg [3:0] i, j, k;

    // Control Signals
    reg compute_done;

    integer idx; // For loops

    // FSM and Data Path in One Always Block
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers and counters
            state <= S1_IDLE;
            n <= 0;
            m <= 0;
            p <= 0;
            count_a <= 0;
            count_b <= 0;
            count_c <= 0;
            idx_a <= 0;
            idx_b <= 0;
            idx_c <= 0;
            i <= 0;
            j <= 0;
            k <= 0;
            compute_done <= 0;
            strobe <= 0;
            dout <= 0;
            // Initialize arrays
            for (idx = 0; idx < max_n*max_m; idx = idx + 1)
                A_flat[idx] <= 0;
            for (idx = 0; idx < max_m*max_p; idx = idx + 1)
                B_flat[idx] <= 0;
            for (idx = 0; idx < max_n*max_p; idx = idx + 1)
                C_flat[idx] <= 0;
        end else begin
            case (state)
                S1_IDLE: begin
                    strobe <= 0;
                    dout <= 0;
                    compute_done <= 0;
                    if (start)
                        state <= S2_READ_N;
                end
                S2_READ_N: begin
                    n <= din1[3:0]; // Assuming n fits within 4 bits
                    state <= S3_READ_M;
                end
                S3_READ_M: begin
                    m <= din1[3:0];
                    state <= S4_READ_P;
                end
                S4_READ_P: begin
                    p <= din1[3:0];
                    // Initialize counters
                    count_a <= 0;
                    count_b <= 0;
                    count_c <= 0;
                    idx_a <= 0;
                    idx_b <= 0;
                    idx_c <= 0;
                    i <= 0;
                    j <= 0;
                    k <= 0;
                    // Initialize C_flat to zero
                    for (idx = 0; idx < max_n*max_p; idx = idx + 1) begin
                        C_flat[idx] <= 0;
                    end
                    state <= S5_READ_A;
                end
                S5_READ_A: begin
                    // Read matrix A elements from din1
                    A_flat[count_a] <= din1;
                    if (count_a < n*m - 1) begin
                        count_a <= count_a + 1;
                    end else begin
                        count_a <= 0; // Reset count_a
                        state <= S6_READ_B;
                    end
                end
                S6_READ_B: begin
                    // Read matrix B elements from din2
                    B_flat[count_b] <= din2;
                    if (count_b < m*p - 1) begin
                        count_b <= count_b + 1;
                    end else begin
                        count_b <= 0; // Reset count_b
                        state <= S7_COMPUTE;
                    end
                end
                S7_COMPUTE: begin
                    // Start computation
                    if (!compute_done) begin
                        // Perform multiplication and accumulation
                        idx_a = i * m + k;
                        idx_b = k * p + j;
                        idx_c = i * p + j;
                        C_flat[idx_c] <= C_flat[idx_c] + A_flat[idx_a] * B_flat[idx_b];

                        if (k < m - 1) begin
                            k <= k + 1;
                        end else begin
                            k <= 0;
                            if (j < p - 1) begin
                                j <= j + 1;
                            end else begin
                                j <= 0;
                                if (i < n - 1) begin
                                    i <= i + 1;
                                end else begin
                                    // Computation done
                                    compute_done <= 1;
                                    i <= 0; // Reset indices for output
                                    j <= 0;
                                    idx_c <= 0;
                                    state <= S8_OUTPUT;
                                end
                            end
                        end
                    end
                end
                S8_OUTPUT: begin
                    // Output the elements of the result matrix C_flat
                    strobe <= 1;
                    dout <= C_flat[idx_c][46:20]; // Adjust bits to match output size
                    if (idx_c < n*p - 1) begin
                        idx_c <= idx_c + 1;
                    end else begin
                        strobe <= 0; // Deassert strobe after last element
                        state <= S1_IDLE; // Go back to idle state
                    end
                end
                default: state <= S1_IDLE;
            endcase
        end
    end

endmodule