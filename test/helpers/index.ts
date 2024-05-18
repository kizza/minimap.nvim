import { NeovimClient, getBuffer } from "nvim-test-js";

export interface Match {
  group: string
  id: number
  priority: number
  pos1: number[]
}

export const waitUntil = (promise: any, attempts: number, delay: number = 0) =>
  new Promise((resolve, reject) => {
    const retry = (count: number) => {
      promise()
        .then(resolve)
        .catch(() => {
          console.log("Nope", attempts)
          if (count === 0) {
            reject();
          } else {
            wait(delay).then(() => retry(count - 1));
          }
        });
    };

    retry(attempts);
  });

export const wait = (timeout: number) =>
  new Promise((resolve, _) => {
    setTimeout(resolve, timeout);
  });

export default (nvim: NeovimClient) => {
  const get = <T>(execute: string) => nvim.commandOutput(`echo ${execute}`) as Promise<T>

  const call = (fun: string) => nvim.command(`call ${fun}`)

  const bufferCount = () => get<number>('len(getbufinfo({"buflisted":1}))')

  const gotoWindow = (windowNumber: number) => call(`win_gotoid(win_getid(${windowNumber}))`)

  const getMinimapWindow = () => get<number>('bufwinnr("~minimap~")')
  const getMinimapWindowId = () => get<number>('win_getid(bufwinnr("~minimap~"))')

  const withWindow = async <T>(windowNumber: number, fun: () => T) => {
    const currentWindow = await get<number>('winnr()')
    await gotoWindow(windowNumber)
    const result = await fun()
    await gotoWindow(currentWindow)
    return result
  }

  const withinMinimap = async <T>(fun: () => T) =>
    withWindow(await getMinimapWindow(), fun)

  const getMinimapText = () => withinMinimap(() => getBuffer(nvim))

  const getMinimapMatches = () => withinMinimap(
    () => nvim.call('getmatches') as Promise<Match[]>
  )

  return {
    bufferCount,
    call,
    get,
    getMinimapMatches,
    getMinimapText,
    getMinimapWindow,
    getMinimapWindowId,
    gotoWindow,
    withinMinimap,
  }
}
