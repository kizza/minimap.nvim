import assert from "assert";
import * as path from "path";
import fs from "fs";
import { WithVim, delay, setBuffer } from "nvim-test-js";
import buildHelpers from "./helpers";
import withPlugin, { defaultPluginOptions, withoutPlugin } from "./helpers/vim";
import { stringify } from "./helpers/lua";

const withVim = (fn: WithVim) => withPlugin(defaultPluginOptions, fn)

describe("sanity check", () => {
  it("gives me the vim", () =>
    withVim(async nvim => {
      const result = await nvim.commandOutput('echo "It works!"');
      assert.equal(result, "It works!");
    }));

  it("loads minimap plugin", () =>
    withVim(async nvim => {
      const loaded = (await nvim.getVar("loaded_minimap")) as boolean;
      assert.equal(loaded, true);
    }));

  it("opens reads the buffer fixture", () =>
    withVim(async nvim => {
      await nvim.command('edit fixtures/buffer.txt')
      const currentBufferPath = await nvim.commandOutput(`echo expand("%")`)
      assert.equal(currentBufferPath, "fixtures/buffer.txt")
      const lines = await nvim.buffer.lines
      assert.equal(lines.toString(), ['aaa', 'bb', 'c'].toString())
    }));
})

describe("buffer management", () => {
  describe("single buffer", () => {
    it("opens the minimap when opening a buffer", () =>
      withVim(async nvim => {
        const { get, getMinimapText } = buildHelpers(nvim)

        // Minimap window opens when buffer does
        assert.equal(await get('winnr("$")'), "1")
        await nvim.command('edit fixtures/buffer.txt');
        assert.equal(await get('winnr("$")'), "2")

        // Current window is still the first
        assert.equal(await get('winnr()'), "1")

        // Minimap text is set
        const lines = await getMinimapText()
        assert.equal(lines, '⠟⠁        ')
      }));

    it("closes the minimap when closing the buffer", () =>
      withVim(async nvim => {
        const { get } = buildHelpers(nvim)

        await nvim.command('edit fixtures/buffer.txt');
        assert.equal(await get('winnr("$")'), "2")

        await nvim.command('bdelete')
        assert.equal(await get('winnr("$")'), "1")
      }));

    it("reopens when opening a new buffer after closed", () =>
      withVim(async nvim => {
        const { get, withinMinimap } = buildHelpers(nvim)

        await nvim.command('edit fixtures/buffer.txt');

        await withinMinimap(() =>nvim.command('bdelete'))
        assert.equal(await get('winnr("$")'), "1")

        await nvim.command('edit fixtures/buffer_two.txt');
        assert.equal(await get('winnr("$")'), "2")
      }));

    // it("quites when the last buffer is quit", () =>
    //   withVim(async nvim => {
    //     const { get } = buildHelpers(nvim)

    //     await nvim.command('edit fixtures/buffer.txt');
    //     assert.equal(await get('winnr("$")'), "2")

    //     await nvim.command('q')
    //     // assert.equal(await get('winnr("$")'), "0")
    //   }));
  });

  describe("multiple buffers", () => {
    it("when closing buffer, returns to the previous buffer", () =>
      withVim(async nvim => {
        const { bufferCount, getMinimapText } = buildHelpers(nvim)

        await nvim.command('edit fixtures/buffer.txt');
        assert.equal(await getMinimapText(), '⠟⠁        ')
        assert.equal(await bufferCount(), 1)

        await delay(800) // Buffer history order is by time, so need a slight delay

        await nvim.command('edit fixtures/buffer_two.txt');
        assert.equal(await getMinimapText(), '⠿⠇        ')
        assert.equal(await bufferCount(), 2)

        await nvim.command('bdelete');
        assert.equal(await getMinimapText(), '⠟⠁        ')
        assert.equal(await bufferCount(), 1)
      }));

    describe("with lazily loaded", () =>
      it("opens the minimap for an already opened buffer", () =>
        withoutPlugin(async nvim => {
          const { getMinimapText } = buildHelpers(nvim)

          await nvim.command('edit fixtures/buffer.txt');
          await nvim.executeLua(`require("minimap").setup(${stringify(defaultPluginOptions)})`)

          assert.equal(await getMinimapText(), '⠟⠁        ')
        })))
  });
});

describe("tab management", () => {
  it("opens the minimap when opening a new tab", () =>
    withVim(async nvim => {
      const { bufferCount, get, getMinimapText, getMinimapWindowId } = buildHelpers(nvim)

      // Minimap window opens when buffer does
      assert.equal(await get('winnr("$")'), "1")
      await nvim.command('edit fixtures/buffer.txt');
      assert.equal(await getMinimapText(), '⠟⠁        ')

      // Open another buffer in a tab
      await nvim.command('tabedit fixtures/buffer_two.txt');
      assert.equal(await get('tabpagenr("$")'), "2")
      assert.equal(await getMinimapText(), '⠿⠇        ')
      assert.equal(await bufferCount(), 2)

      // Assert on tab details
      const raw = await get<any>('gettabinfo()')
      const tabinfo = JSON.parse(raw.replace(/'/g, '"'));
      assert.equal(tabinfo.length, 2) // Two tabs
      assert.equal(tabinfo[0].windows.length, 1) // First with only one window
      assert.equal(tabinfo[1].windows.length, 2) // Second with two (ie. minimap)

      // Assert current tab's second window is new minimap
      const minimapWindowId = await getMinimapWindowId()
      assert.equal(tabinfo[1].windows[1], minimapWindowId)
    }));
})

describe("live updates", () => {
  it("updates the minimap when changed", () =>
    withVim(async nvim => {
      const { getMinimapText } = buildHelpers(nvim)

      await nvim.command('edit fixtures/buffer.txt');
      assert.equal(await getMinimapText(), '⠟⠁        ')

      await setBuffer(nvim, ['aaa', 'bbb', 'ccc'])
      await delay(10)
      assert.equal(await getMinimapText(), '⠿⠇        ')
    }));
})

describe("painting", () => {
  it("paints the minimap", () =>
    withVim(async nvim => {
      const { getMinimapMatches } = buildHelpers(nvim)

      await nvim.command('edit fixtures/buffer.txt');

      const matches = await getMinimapMatches()
      assert.equal(matches.length, 2)
      assert.equal(matches[0].group, "MinimapViewport")
      assert.equal(matches[1].group, "MinimapCursorLine")
    }));
})
