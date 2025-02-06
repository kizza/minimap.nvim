import { WithVim, vimRunner } from "nvim-test-js";
import * as path from "path";
import { stringify } from "./lua";

export interface PluginOptions {
  width: number
  debounce: {
    build: number
    paint: number
  }
}

export const defaultPluginOptions: Partial<PluginOptions> = {
  width: 10,
  debounce: {
    build: 0,
    paint: 0,
  }
}

export const withoutPlugin = (fn: WithVim) =>
  vimRunner({vimrc: path.resolve(__dirname, "../vimrc.vim")})(fn)

export const withPlugin = (options: Partial<PluginOptions> | Object, fn: WithVim) =>
  withoutPlugin(nvim =>
    nvim
      .executeLua(`require("minimap").setup(${stringify(options)})`)
      .then(() => fn(nvim))
  )

export default withPlugin
