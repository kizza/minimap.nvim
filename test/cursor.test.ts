import assert from "assert";
import { NeovimClient, WithVim, delay } from "nvim-test-js";
import buildHelpers from "./helpers";
import withPlugin from "./helpers/vim";

const withVim = (fn: WithVim) => withPlugin({
  width: 10,
  debounce: {
    build: 0,
    paint: 0,
  }
}, fn)

const getBufferMetrics = async (nvim: NeovimClient) => {
  const { get, getMinimapWindow } = buildHelpers(nvim)

  const bufferWinNumber = await get<number>('winnr()')
  const bufferWinId = await get<number>(`win_getid(${bufferWinNumber})`)
  const bufferLineLength = await get<number>(`nvim_buf_line_count(${bufferWinNumber})`)

  const minimapWinNumber = await getMinimapWindow();
  const minimapWinId = await get<number>(`win_getid(${minimapWinNumber})`);
  const mapLineLength = await get<number>(`nvim_buf_line_count(${minimapWinNumber})`)

  return {bufferWinId, minimapWinId, bufferLineLength, mapLineLength}
}

describe("cursor movement", () => {
  describe("from mapped buffer", () => {
    it("updates minimap cursor", () =>
      withVim(async nvim => {
        const { get } = buildHelpers(nvim)
        await nvim.command('edit fixtures/buffer_long.txt')

        const {bufferWinId, minimapWinId, bufferLineLength, mapLineLength} = await getBufferMetrics(nvim)
        const getCurrentLine = (windowId: number) => get<number>(`nvim_win_get_cursor(${windowId})[0]`)

        // Starts at top
        assert.equal(await getCurrentLine(bufferWinId), 1)
        assert.equal(await getCurrentLine(minimapWinId), 1)

        // Moves to bottom
        await nvim.command(`execute("normal G")`)
        assert.equal(await getCurrentLine(bufferWinId), bufferLineLength)
        assert.equal(await getCurrentLine(minimapWinId), mapLineLength)

        // Back to top
        await nvim.command(`execute("normal gg")`)
        assert.equal(await getCurrentLine(bufferWinId), 1)
        assert.equal(await getCurrentLine(minimapWinId), 1)
      }))

    it("correctly evaluates the middle point", () =>
      withVim(async nvim => {
        const { get } = buildHelpers(nvim)
        await nvim.command('edit fixtures/buffer_cursor.txt')

        const {bufferWinId, minimapWinId } = await getBufferMetrics(nvim)
        const getCurrentLine = (windowId: number) => get<number>(`nvim_win_get_cursor(${windowId})[0]`)

        // Starts at top
        assert.equal(await getCurrentLine(bufferWinId), 1)
        assert.equal(await getCurrentLine(minimapWinId), 1)

        // Middle
        await nvim.command(`execute("normal M")`)
        assert.equal(await getCurrentLine(bufferWinId), 6)
        assert.equal(await getCurrentLine(minimapWinId), 2)
      }))
  })

  describe("from minimap", () => {
    it("updates buffer cursor", () =>
      withVim(async nvim => {
        const { get, getMinimapWindow, gotoWindow } = buildHelpers(nvim)
        await nvim.command('edit fixtures/buffer_long.txt')

        const {bufferWinId, minimapWinId, bufferLineLength, mapLineLength} = await getBufferMetrics(nvim)
        const getCurrentLine = (windowId: number) => get<number>(`nvim_win_get_cursor(${windowId})[0]`)

        // Go to the minimap (*after* metrics are built)
        await gotoWindow(await getMinimapWindow())
        assert.equal(await get("&filetype"), "minimap")

        // Starts at top
        assert.equal(await getCurrentLine(bufferWinId), 1)
        assert.equal(await getCurrentLine(minimapWinId), 1)

        // Moves to bottom
        await nvim.command(`execute("normal G")`)
        assert.equal(await getCurrentLine(bufferWinId), bufferLineLength)
        assert.equal(await getCurrentLine(minimapWinId), mapLineLength)

        // Back to top
        await nvim.command(`execute("normal gg")`)
        assert.equal(await getCurrentLine(bufferWinId), 1)
        assert.equal(await getCurrentLine(minimapWinId), 1)
      }))

    it("correctly evaluates the middle point", () =>
      withVim(async nvim => {
        const { get, getMinimapWindow, gotoWindow } = buildHelpers(nvim)
        await nvim.command('edit fixtures/buffer_cursor.txt')

        const {bufferWinId, minimapWinId } = await getBufferMetrics(nvim)
        const getCurrentLine = (windowId: number) => get<number>(`nvim_win_get_cursor(${windowId})[0]`)

        // Go to the minimap (*after* metrics are built)
        await gotoWindow(await getMinimapWindow())
        assert.equal(await get("&filetype"), "minimap")

        // Starts at top
        assert.equal(await getCurrentLine(bufferWinId), 1)
        assert.equal(await getCurrentLine(minimapWinId), 1)

        // Middle
        await nvim.command(`execute("normal M")`)
        assert.equal(await getCurrentLine(bufferWinId), 6)
        assert.equal(await getCurrentLine(minimapWinId), 2)
      }))
  })
})
