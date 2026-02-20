import { Command } from "commander";
import { registerProgramCommands } from "./command-registry.js";
import { createProgramContext } from "./context.js";
import { configureProgramHelp } from "./help.js";
import { registerPreActionHooks } from "./preaction.js";
import { setProgramContext } from "./program-context.js";

export function buildProgram() {
  const program = new Command();
  const ctx = createProgramContext();
  const argv = process.argv;

  setProgramContext(program, ctx);
  configureProgramHelp(program, ctx);
  registerPreActionHooks(program, ctx.programVersion);

  // enablePositionalOptions makes option parsing positional: options after a
  // subcommand name are parsed by that subcommand, not the parent. This prevents
  // the gateway parent command (which owns --token for `gateway run`) from
  // consuming --token meant for `gateway call --token`.
  program.enablePositionalOptions();

  registerProgramCommands(program, ctx, argv);

  return program;
}
