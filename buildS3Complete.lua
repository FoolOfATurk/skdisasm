#!/usr/bin/env lua

--------------
-- Settings --
--------------

-- Set this to true to use a better compression algorithm for the sound driver.
-- Having this set to false will use an inferior compression algorithm that
-- results in an accurate ROM being produced.
local improved_sound_driver_compression = false

---------------------
-- End of settings --
---------------------

local common = require "build_tools.lua.common"

local assemble_result = common.assemble_file("SubCPU/subcpu.asm", "SubCPU/subcpu.bin", "", "", false, repository)

if assemble_result == "crash" then
	print "\n\z
		**********************************************************************\n\z
		*                                                                    *\n\z
		*         The assembler crashed. See above for more details.         *\n\z
		*                                                                    *\n\z
		**********************************************************************\n\z"

	os.exit(false)
elseif assemble_result == "error" then
	print "\n\z
		**********************************************************************\n\z
		*                                                                    *\n\z
		*        There were build errors. See s2.log for more details.       *\n\z
		*                                                                    *\n\z
		**********************************************************************\n\z"

	os.exit(false)
end

local compression = improved_sound_driver_compression and "kosinski-optimised" or "kosinski"
local message, abort = common.build_rom("sonic3k", "sonic3k", "-D Sonic3_Complete=1", "-p=FF -z=0," .. compression .. ",Size_of_Snd_driver_guess,before -z=1300," .. compression .. ",Size_of_Snd_driver2_guess,before", false, "https://github.com/sonicretro/skdisasm")

if message then
	exit_code = false
end

if abort then
	os.exit(exit_code, true)
end

-- Correct the ROM's header with a proper checksum and end-of-ROM value.
common.fix_header("sonic3k.bin")

os.exit(exit_code, false)
