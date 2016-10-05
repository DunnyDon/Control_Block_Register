-- Synthesisable VHDL model for eight, writeable byte-wide control register bank
-- Created :    Dec 2004. F Morgan, P Rocke
--              Oct 2014. Additional comments. F Morgan.
--              Oct 2014. Extended to 16-byte register. F Morgan

-- Describe using two process VHDL model
-- NSDecode: if enCtrlRegWr asserted, load addressed ctrlReg register with i/p data byte
--    use TO_INTEGER (provided in ieee.numeric_std library), syntax: TO_INTEGER(unsigned(vector))); 
--    requires unsigned vector input, so first convert type std_logic_vector type to unsigned, using unsigned(vector signal name)

-- ctrlRegOut:  
-- Could use a process to describe this, though more efficient to use a single concurrent statement
-- Again, type conversion is required to generate integer value of ctrlRegAdd(3:0) std_logic_vector type 

-- declare internal signals NS and CS, typical names used for next and current state

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ctrlRegBlkPackage.all; -- package defining byte array

entity ctrlRegBlk is
 Port (
         clk		: in std_logic;    					-- system clock strobe, low-to-high active edge
		 rst		: in std_logic;    					-- system reset, asserted high
		 ctrlRegAdd : in std_logic_vector(3 downto 0);  -- register address
		 enCtrlRegWr: in std_logic;                     -- register write enable, asserted high
		 ctrlRegIn 	: in std_logic_vector(7 downto 0);  -- data byte (to be written)
		 ctrlReg 	: out array16Byte;                  -- array of ctrlReg bytes
		 ctrlRegOut : out std_logic_vector(7 downto 0)  -- addressed ctrlReg data byte
 		 );
end ctrlRegBlk;

architecture RTL of ctrlRegBlk is
signal CS : array16Byte :=(others =>"00000000");  -- current state signal
signal NS : array16Byte;  -- next state signal]
signal temp: integer range 7 downto 0;

begin
NSDecode_i: process(ctrlRegAdd,enCtrlRegWr,ctrlRegIn)
begin
    NS<=CS;
    if enCtrlRegWr='1' then
        NS(TO_INTEGER(unsigned(ctrlRegAdd)))<=ctrlRegIn;
    end if;
end process;

stateReg_i: process(clk,rst)
begin
    if rst='1' then
        CS<=(others =>"00000000");
    elsif clk'event and clk='1' then
        CS<=NS;
    end if;
end process;

asgnCtrlReg_i: process(CS)
begin
    ctrlReg<=CS;        
end process;

ctrlRegOut_i: process(CS) 
begin
    ctrlRegOut<=CS(TO_INTEGER(unsigned(ctrlRegAdd)));
end process;

end RTL;
