import assert from "assert";
import { WithVim } from "nvim-test-js";
import buildHelpers from "./helpers";
import withPlugin from "./helpers/vim";

const withVim = (fn: WithVim) => withPlugin({
  map: {
    width: 12
  }
}, fn)

describe("search highlighting", () => {
  it("has a test setup with 12 wide minimap", () =>
    withVim(async nvim => {
      const { get, withinMinimap } = buildHelpers(nvim)
      await nvim.command('edit fixtures/buffer_search.txt')

      const width = await withinMinimap(() => get<number>("winwidth(0)"))
      assert.equal(width, 12)
    })
  )

  it("works", () =>
    withVim(async nvim => {
      await nvim.command('edit fixtures/buffer_search.txt')
      const { getMinimapMatches } = buildHelpers(nvim)

      let matches = await getMinimapMatches()
      let searchHighlights = matches.filter(match => match.group.startsWith("MinimapSearch"))
      assert.equal(searchHighlights.length, 0)

      await nvim.command(`execute('call feedkeys(\"/find\\<CR>\")')`)

      matches = await getMinimapMatches()
      searchHighlights = matches.filter(match => match.group.startsWith("MinimapSearch"))
      assert.equal(searchHighlights.length, 3)
      assert.equal(JSON.stringify(searchHighlights[0].pos1), "[1,1,4]")
      assert.equal(JSON.stringify(searchHighlights[1].pos1), "[2,15,6]")
      assert.equal(JSON.stringify(searchHighlights[2].pos1), "[3,30,6]")
    }));
})
