module Pci_Target(clk,Ad,CBE,Frame,Trdy,Irdy,Dev_sel,rst);
//inputs, outputs and inouts
input clk;
inout [31:0] Ad;
input [3:0] CBE;
input Frame,Irdy;
input rst;
output reg Trdy;
output reg Dev_sel;
//internal 
reg Read;
reg Read2;
parameter [3:0] start = 4'b0000;
parameter [3:0] read_trans = 4'b0010;//read from first buffer
parameter [3:0] read_trans2 = 4'b0011;//read from second buffer
parameter [3:0] write_trans = 4'b0100;//write in first buffer
parameter [3:0] write_trans2 = 4'b0110;//write in second buffer
parameter [3:0] last_read = 4'b1100;
parameter [3:0] last_write = 4'b1001;
parameter [3:0] finish_trans = 4'b1000;
reg [3:0]State;
reg[31:0] memory[0:3];
reg[31:0] memory2[0:7];
reg[31:0] data;//output on data bus
reg[3:0] pointer;//pointer of memory 
//turnaround in read operation
reg delayed_trdy;
reg delayed_devsel;
// execution of states
always @(negedge clk)
begin
if(rst==1'b0)
begin
State<=start;
end
State<=start;
case(State)
start:
begin

Trdy<=1'b1;
	Dev_sel<=1'b1;
	Read<=1'b0;
	if(Ad>=2'b00 && Ad<2'b11 && Frame==1'b0)
	begin
		
		if(CBE==4'b0010)
		begin
			Read<=1'b1;
			delayed_trdy=1'b0;
			delayed_devsel=1'b0;
			pointer<=Ad;
			State<=(Read2)?read_trans2:read_trans;
		end
		if(CBE==4'b0011)
		begin
			Trdy<=1'b0;
			Dev_sel<=1'b0;
			State<=write_trans;
			pointer<=Ad;
		end
	end
	else
	begin
		State<=start;
	end
end
read_trans:
    begin
        if (Frame== 1'b0&&Irdy==1'b0)
        begin
		Trdy<=delayed_trdy;
		Dev_sel<=delayed_devsel;
		data<=memory[pointer];
		State <= read_trans;
		if (pointer==2'b10)
		begin
			pointer<=2'b00;
		end
		else
		begin
			pointer<=pointer+2'b01;
		end
        end
else if(Frame== 1'b1&&Irdy==1'b0)
State<=last_read;
        else
		
            State <= finish_trans;
    end
read_trans2:
begin
        if (Frame== 1'b0&&Irdy==1'b0)
        begin
		Trdy<=delayed_trdy;
		Dev_sel<=delayed_devsel;
		data<=memory2[pointer];
		State <= read_trans2;
		if (pointer==3'b111)
		begin
			pointer<=3'b000;
		end
		else
		begin
			pointer<=pointer+3'b001;
		end
        end
else if(Frame== 1'b1&&Irdy==1'b0)
begin
State<=last_read;
end
        else
	begin
		State <= finish_trans;
	end
    end
write_trans:
begin
if(Irdy==1'b0&&Frame==1'b0)
begin
	if (pointer==2'b11)
	begin
		Trdy<=1'b1;
		State<=write_trans2;
	end
	else
	begin
		Read2<=1'b0;
		
		if(CBE[0]) begin
			memory[pointer][7]<=Ad[7];
			memory[pointer][6]<=Ad[6];
			memory[pointer][5]<=Ad[5];
			memory[pointer][4]<=Ad[4];
			memory[pointer][3]<=Ad[3];
			memory[pointer][2]<=Ad[2];
			memory[pointer][1]<=Ad[1];
			memory[pointer][0]<=Ad[0];
	        end
	        if(CBE[1]) begin
			memory[pointer][8]<=Ad[8];
			memory[pointer][9]<=Ad[9];
			memory[pointer][10]<=Ad[10];
			memory[pointer][11]<=Ad[11];
			memory[pointer][12]<=Ad[12];
			memory[pointer][13]<=Ad[13];
			memory[pointer][14]<=Ad[14];
			memory[pointer][15]<=Ad[15];
		           
	        end
	        if(CBE[2]) begin
			memory[pointer][16]<=Ad[16];
			memory[pointer][17]<=Ad[17];
			memory[pointer][18]<=Ad[18];
			memory[pointer][19]<=Ad[19];
			memory[pointer][20]<=Ad[20];
			memory[pointer][21]<=Ad[21];
			memory[pointer][22]<=Ad[22];
			memory[pointer][23]<=Ad[23];
		           
	        end
	        if(CBE[3]) begin
			memory[pointer][24]<=Ad[24];
			memory[pointer][25]<=Ad[25];
			memory[pointer][26]<=Ad[26];
			memory[pointer][27]<=Ad[27];
			memory[pointer][28]<=Ad[28];
			memory[pointer][29]<=Ad[29];
			memory[pointer][30]<=Ad[30];
			memory[pointer][31]<=Ad[31];
		           
	        end
		
			pointer<=pointer+4'b0001;
			State <= write_trans;
		
	end
end
else if(Frame== 1'b1&&Irdy==1'b0)
begin
State<=last_write;
end
else
	State <= finish_trans;
end
write_trans2:
begin
	memory2[2]<=memory[2];
	memory2[1]<=memory[1];
	memory2[0]<=memory[0];
	Trdy<=0;
	Read2<=1'b1;
	if(Irdy==1'b0&&Frame==1'b0)
	begin
		
		if(CBE[0]) begin
			memory2[pointer][7]<=Ad[7];
			memory2[pointer][6]<=Ad[6];
			memory2[pointer][5]<=Ad[5];
			memory2[pointer][4]<=Ad[4];
			memory2[pointer][3]<=Ad[3];
			memory2[pointer][2]<=Ad[2];
			memory2[pointer][1]<=Ad[1];
			memory2[pointer][0]<=Ad[0];
	        end
	        if(CBE[1]) begin
			memory2[pointer][8]<=Ad[8];
			memory2[pointer][9]<=Ad[9];
			memory2[pointer][10]<=Ad[10];
			memory2[pointer][11]<=Ad[11];
			memory2[pointer][12]<=Ad[12];
			memory2[pointer][13]<=Ad[13];
			memory2[pointer][14]<=Ad[14];
			memory2[pointer][15]<=Ad[15];
		           
	        end
	        if(CBE[2]) begin
			memory2[pointer][16]<=Ad[16];
			memory2[pointer][17]<=Ad[17];
			memory2[pointer][18]<=Ad[18];
			memory2[pointer][19]<=Ad[19];
			memory2[pointer][20]<=Ad[20];
			memory2[pointer][21]<=Ad[21];
			memory2[pointer][22]<=Ad[22];
			memory2[pointer][23]<=Ad[23];
		           
	        end
	        if(CBE[3]) begin
			memory2[pointer][24]<=Ad[24];
			memory2[pointer][25]<=Ad[25];
			memory2[pointer][26]<=Ad[26];
			memory2[pointer][27]<=Ad[27];
			memory2[pointer][28]<=Ad[28];
			memory2[pointer][29]<=Ad[29];
			memory2[pointer][30]<=Ad[30];
			memory2[pointer][31]<=Ad[31];
		           
	        end
		
			pointer<=pointer+4'b0001;
			State <= write_trans2;
		
	end
else if(Frame== 1'b1&&Irdy==1'b0)
begin
State<=last_write;
end
	else
		State <= finish_trans;
end
last_read:
begin
data<=memory[pointer];
State <= finish_trans;
end
last_write:
begin
if(CBE[0]) begin
			memory[pointer][7]<=Ad[7];
			memory[pointer][6]<=Ad[6];
			memory[pointer][5]<=Ad[5];
			memory[pointer][4]<=Ad[4];
			memory[pointer][3]<=Ad[3];
			memory[pointer][2]<=Ad[2];
			memory[pointer][1]<=Ad[1];
			memory[pointer][0]<=Ad[0];
	        end
	        if(CBE[1]) begin
			memory[pointer][8]<=Ad[8];
			memory[pointer][9]<=Ad[9];
			memory[pointer][10]<=Ad[10];
			memory[pointer][11]<=Ad[11];
			memory[pointer][12]<=Ad[12];
			memory[pointer][13]<=Ad[13];
			memory[pointer][14]<=Ad[14];
			memory[pointer][15]<=Ad[15];
		           
	        end
	        if(CBE[2]) begin
			memory[pointer][16]<=Ad[16];
			memory[pointer][17]<=Ad[17];
			memory[pointer][18]<=Ad[18];
			memory[pointer][19]<=Ad[19];
			memory[pointer][20]<=Ad[20];
			memory[pointer][21]<=Ad[21];
			memory[pointer][22]<=Ad[22];
			memory[pointer][23]<=Ad[23];
		           
	        end
	        if(CBE[3]) begin
			memory[pointer][24]<=Ad[24];
			memory[pointer][25]<=Ad[25];
			memory[pointer][26]<=Ad[26];
			memory[pointer][27]<=Ad[27];
			memory[pointer][28]<=Ad[28];
			memory[pointer][29]<=Ad[29];
			memory[pointer][30]<=Ad[30];
			memory[pointer][31]<=Ad[31];
		           
	        end
		
			State <= finish_trans;
		
end
finish_trans:
begin
if(Frame==1'b1)
begin
Trdy<=1'b1;
Dev_sel<=1'b1;
State<=start;
Read<=1'b0;
end
else
State<=finish_trans;
end
endcase
end
assign Ad = ((Read)&&(Frame==1'b0)&&(Irdy==1'b0))? data: 32'bZ;
endmodule
////////////////////////////////////////////////////////////////////////
module Clockgen(clock);
output reg clock;
initial 
clock=0;
always
#5 clock=~clock; 
endmodule
////////////////////////////////////////////////////////////////////////
module testbench1();
reg[31:0]Ad_t_reg;
wire[31:0]Ad_t;
reg[3:0]CBE_t;
reg Frame_t;
wire Trdy_t;
reg Irdy_t;
wire Dev_sel_t;
reg rst;
reg flag;
initial 
begin
rst=1;
Frame_t=1'b1;
Irdy_t=1'b1;
flag=1'b1;
#10 
Frame_t=1'b0;
Ad_t_reg=32'b0000_0000_0000_0000_0000_0000_0000_0000;
CBE_t=4'b0011;
#10
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0101_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0111;
#40
Frame_t=1'b0;
Irdy_t=1'b0;
#20
Frame_t=1'b1;
Irdy_t=1'b1;
#30
Frame_t=1'b0;
CBE_t=4'b0010;
Irdy_t=1'b0;
Ad_t_reg=32'b0000_0000_0000_0000_0000_0000_0000_0000;
#10
flag=1'b0;
#30
Frame_t=1'b1;
Irdy_t=1'b1;
flag=1'b1;
end
Clockgen c1(clk);
assign Ad_t=(flag)?Ad_t_reg:32'bz;
Pci_Target p1(clk,Ad_t,CBE_t,Frame_t,Trdy_t,Irdy_t,Dev_sel_t,rst);
initial
	$monitor($time,,clk,Frame_t,Irdy_t,,Ad_t,,Trdy_t,Dev_sel_t);

endmodule
///////////////////////////////////////////////////////////////////////////////
module testbench2();
reg[31:0]Ad_t_reg;
wire[31:0]Ad_t;
reg[3:0]CBE_t;
reg Frame_t;
wire Trdy_t;
reg Irdy_t;
wire Dev_sel_t;
reg rst;
reg flag;
initial 
begin
rst=1;
Frame_t=1'b1;
Irdy_t=1'b1;
flag=1'b1;
#10
Frame_t=1'b0;
Ad_t_reg=32'b0000_0000_0000_0000_0000_0000_0000_0000;
CBE_t=4'b0011;
#10
Ad_t_reg=32'b0110_0111_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0101;
Irdy_t=1'b0;
#10
CBE_t=4'b0011;
#5
Frame_t=1'b1;
#10
Ad_t_reg=32'b1110_0101_0011_0000_1000_1100_1011_0000;
CBE_t=4'b0110;
Irdy_t=1'b1;
#30
Frame_t=1'b0;
CBE_t=4'b0010;
Ad_t_reg=32'b0000_0000_0000_0000_0000_0000_0000_0000;
#5
Irdy_t=1'b0;
#10
flag=1'b0;
#50
Frame_t=1'b1;
Irdy_t=1'b1;
flag=1'b1;
end
Clockgen c1(clk);
assign Ad_t=(flag)?Ad_t_reg:32'bz;
Pci_Target p1(clk,Ad_t,CBE_t,Frame_t,Trdy_t,Irdy_t,Dev_sel_t,rst);

endmodule
/////////////////////////////////////////////////////////////////////////////
module testbench3();//closing frame before writing data 3 
reg[31:0]Ad_t_reg;
wire[31:0]Ad_t;
reg[3:0]CBE_t;
reg Frame_t;
wire Trdy_t;
reg Irdy_t;
wire Dev_sel_t;
reg rst;
reg flag;
initial 
begin
rst=1;
Frame_t=1'b1;
Irdy_t=1'b1;
flag=1'b1;
#10
Frame_t=1'b0;
Ad_t_reg=32'b0000_0000_0000_0000_0000_0000_0000_0000;
CBE_t=4'b0011;
#10
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0111_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0101;
#10
CBE_t=4'b0011;
Frame_t=1'b1;
#5
Ad_t_reg=32'b1110_0101_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0110;
#40
Frame_t=1'b1;
Irdy_t=1'b1;
#20
Frame_t=1'b1;
Irdy_t=1'b1;
#30
Frame_t=1'b0;
CBE_t=4'b0010;
Ad_t_reg=32'b0000_0000_0000_0000_0000_0000_0000_0000;
#10
flag=1'b0;
#5
Irdy_t=1'b0;
#40
Frame_t=1'b1;
Irdy_t=1'b1;
flag=1'b1;
end
Clockgen c1(clk);
assign Ad_t=(flag)?Ad_t_reg:32'bz;
Pci_Target p1(clk,Ad_t,CBE_t,Frame_t,Trdy_t,Irdy_t,Dev_sel_t,rst);


endmodule
/////////////////////////////////////////////////////////////////////////////
module testbench4();
reg[31:0]Ad_t_reg;
wire[31:0]Ad_t;
reg[3:0]CBE_t;
reg Frame_t;
wire Trdy_t;
reg Irdy_t;
wire Dev_sel_t;
reg rst;
reg flag;
initial 
begin
rst=1;
Frame_t=1'b1;
Irdy_t=1'b1;
flag=1'b1;
#10
Frame_t=1'b0;
Ad_t_reg=32'b0000_0000_0000_0000_0000_0000_0000_0000;
CBE_t=4'b0011;
#10
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0111_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0101;
#10
CBE_t=4'b0011;
#5
Ad_t_reg=32'b1110_0101_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0110;
Irdy_t=1'b1;
#40
Frame_t=1'b1;
#20
Frame_t=1'b1;
Irdy_t=1'b1;
#30
Frame_t=1'b0;
CBE_t=4'b0010;
Ad_t_reg=32'b0000_0000_0000_0000_0000_0000_0000_0000;
#10
flag=1'b0;
#5
Irdy_t=1'b0;
#40
Frame_t=1'b1;
Irdy_t=1'b1;
flag=1'b1;
end
Clockgen c1(clk);
assign Ad_t=(flag)?Ad_t_reg:32'bz;
Pci_Target p1(clk,Ad_t,CBE_t,Frame_t,Trdy_t,Irdy_t,Dev_sel_t,rst);
endmodule


//////////////////////////////////////////////////////////////////////////////

module testbench5();     
reg[31:0]Ad_t_reg;
wire[31:0]Ad_t;
reg[3:0]CBE_t;
reg Frame_t;
wire Trdy_t;
reg Irdy_t;
wire Dev_sel_t;
reg rst;
reg flag;
initial 
begin
rst=1;
Frame_t=1'b1;
Irdy_t=1'b1;
flag=1'b1;
#5
Frame_t=1'b0;
Ad_t_reg=32'b0000_0000_0000_0000_0000_0000_0000_0000;
CBE_t=4'b0011;
#10
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0101_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0111;
#10
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0101_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0011;
#10
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0101_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0001;
#20
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0101_0011_0000_1000_1100_1010_0000;
CBE_t=4'b1000;
#20
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0101_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0100;
#10
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0101_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0010;
#10
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0101_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0000;
#10
Frame_t=1'b1;
Irdy_t=1'b1;
#30
Frame_t=1'b0;
CBE_t=4'b0010;
Irdy_t=1'b0;
Ad_t_reg=32'b0000_0000_0000_0000_0000_0000_0000_0000;
#10
flag=1'b0;
#100
Frame_t=1'b1;
Irdy_t=1'b1;
flag=1'b1;
end
Clockgen c1(clk);
assign Ad_t=(flag)?Ad_t_reg:32'bz;
Pci_Target p1(clk,Ad_t,CBE_t,Frame_t,Trdy_t,Irdy_t,Dev_sel_t,rst);
initial
	$monitor($time,,clk,Frame_t,Irdy_t,,Ad_t,,Trdy_t,Dev_sel_t);

endmodule
//////////////////////////////////////////////////////////////////////////////////
module testbench6();     
reg[31:0]Ad_t_reg;
wire[31:0]Ad_t;
reg[3:0]CBE_t;
reg Frame_t;
wire Trdy_t;
reg Irdy_t;
wire Dev_sel_t;
reg rst;
reg flag;
initial 
begin
rst=1;
Frame_t=1'b1;
Irdy_t=1'b1;
flag=1'b1;
#5
Frame_t=1'b0;
Ad_t_reg=32'b0000_0000_0000_0000_0000_0010_0000_0000;
CBE_t=4'b0011;
#10
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0101_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0111;
#10
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0101_0011_0001_1000_1100_1010_0000;
CBE_t=4'b0011;
#20
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0101_0011_0000_1001_1100_1010_0000;
CBE_t=4'b0100;
#10
Irdy_t=1'b0;
Ad_t_reg=32'b0110_0101_0011_0000_1000_1100_1010_0000;
CBE_t=4'b0010;
#10
Frame_t=1'b1;
Irdy_t=1'b1;
#30
Frame_t=1'b0;
CBE_t=4'b0010;
Irdy_t=1'b0;
Ad_t_reg=32'b0000_0000_0000_0000_0000_0010_0000_0000;
#10 
flag=1'b0;
#100
Frame_t=1'b1;
Irdy_t=1'b1;
flag=1'b1;
end
Clockgen c1(clk);
assign Ad_t=(flag)?Ad_t_reg:32'bz;
Pci_Target p1(clk,Ad_t,CBE_t,Frame_t,Trdy_t,Irdy_t,Dev_sel_t,rst);
initial
	$monitor($time,,clk,Frame_t,Irdy_t,,Ad_t,,Trdy_t,Dev_sel_t);

endmodule

