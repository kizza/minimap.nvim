import { WithVim, vimRunner } from "nvim-test-js";
import * as path from "path";
import { stringify } from "./lua";

export interface PluginOptions {
  map: {
    width: number
  }
}

export default (options: Partial<PluginOptions> | Object, fn: WithVim) =>
  vimRunner({
    vimrc: path.resolve(__dirname, "../vimrc.vim"),
  })(async nvim =>
    nvim
      .executeLua(`require("minimap").setup(${stringify(options)})`)
      .then(() => fn(nvim))
  )
