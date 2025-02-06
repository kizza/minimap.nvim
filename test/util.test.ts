import assert from "assert";
import { NeovimClient, WithVim } from "nvim-test-js";
import withPlugin from "./helpers/vim";
import { stringify } from "./helpers/lua";

const withVim = (fn: WithVim) => withPlugin({
  wiuth: 12,
  debounce: {
    build: 0,
    paint: 0,
  }
}, fn)

const lua = (nvim: NeovimClient, fn: string, ...args: any[]) => {
  // console.log(`Executing`, `return require("minimap.util").${fn}(${args.join(", ")})`)
  return nvim.lua(`return require("minimap.util").${fn}(${args.join(", ")})`)
}

describe("util", () => {
  describe("trim_trailing_whitespace", () => {
    it("trims trailing whitespace", () =>
      withVim(async nvim =>
        assert.equal(" text", await lua(nvim, "trim_trailing_whitespace", `" text  "`))
      )
    )})

  describe("round", () => {
    it("rounds up", () =>
      withVim(async nvim => assert.equal(1, await lua(nvim, "round", `0.6`)))
    )

    it("rounds down", () =>
      withVim(async nvim => assert.equal(0, await lua(nvim, "round", `0.4`)))
    )

    it("rounds up when in-between", () =>
      withVim(async nvim => assert.equal(1, await lua(nvim, "round", `0.5`)))
    )
  })

  describe("merge_tables", () => {
    it("folder the second over the first", () =>
      withVim(async nvim => {
        const first = {
          one: "one",
          two: "two",
          child: {
            four: "four"
          },
        }
        const second = {
          two: "2",
          three: "3",
          child: {
            four: "4",
            five: "5"
          },
        }

        const merged = await lua(nvim, "merge_tables", stringify(first), stringify(second))
        assert.deepEqual({
          one: "one",
          two: "2",
          three: "3",
          child: {
            four: "4",
            five: "5",
          }
        }, merged)
      })
    )
  })

  describe("merge_hl_groups", () => {
    const asHex = (colour: number) => `#${colour.toString(16).padStart(6, "0").toUpperCase()}`

    it("creates a merged highlight group", () =>
      withVim(async nvim => {
        const highlights = {fg: "with_foreground", bg: "with_background"}
        await nvim.lua(`vim.api.nvim_set_hl(0, "${highlights.fg}", {fg="#FF0000"})`)
        await nvim.lua(`vim.api.nvim_set_hl(0, "${highlights.bg}", {bg="#00FF00"})`)

        await lua(nvim, "merge_hl_groups", "'merged_highlight'", stringify(highlights))

        const merged = await nvim.lua(`return vim.api.nvim_get_hl_by_name("merged_highlight", true)`) as any
        assert.equal("#FF0000", asHex(merged['foreground']))
        assert.equal("#00FF00", asHex(merged['background']))
      })
    )

    it("is tolerant of missing styles", () =>
      withVim(async nvim => {
        const highlights = {fg: "with_foreground", bg: "with_background"}
        await nvim.lua(`vim.api.nvim_set_hl(0, "${highlights.fg}", {})`)
        await nvim.lua(`vim.api.nvim_set_hl(0, "${highlights.bg}", {})`)

        await lua(nvim, "merge_hl_groups", "'merged_highlight'", stringify(highlights))

        const merged = await nvim.lua(`return vim.api.nvim_get_hl_by_name("merged_highlight", true)`) as any
        assert.equal("{}", JSON.stringify(merged))
      })
    )

    it("throws with missing provided highlights", () =>
      withVim(async nvim =>
        await assert.rejects(
          async () => {
            const highlights = {fg: "with_foreground", bg: "with_background"}
            await lua(nvim, "merge_hl_groups", "'merged_highlight'", stringify(highlights))
          },
          /Invalid highlight name: 'with_foreground'/,
        )
      )
    )
  })
})
