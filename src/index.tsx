/* @refresh reload */
import "./index.css";
import { render } from "solid-js/web";
import { createSignal, onMount } from "solid-js";
import { createShortcut } from "@solid-primitives/keyboard";
import loadWasm from "./assets/tameboy.wasm?init";

const root = document.getElementById("app");

const DisplayScale = 5;
const DisplayWidth = 160;
const DisplayHeight = 144;

let canvas!: HTMLCanvasElement;
let screen!: CanvasRenderingContext2D;

function decodeString(ptr: number, len: number): string {
  const slice = new Uint8Array(memory.buffer, ptr, len);
  return new TextDecoder().decode(slice);
}

const module = await loadWasm({
  env: {
    console_log: (ptr: number, len: number) => {
      const string = decodeString(ptr, len);
      console.log(string);
    },
    updateImageData(img_ptr: number, img_len: number): void {
      console.log("Image Data: ", img_ptr, ", ", img_len);
      let image_buffer = new Uint8ClampedArray(memory.buffer, img_ptr, img_len);
      let image_data = new ImageData(image_buffer, DisplayWidth, DisplayHeight);
      screen.putImageData(image_data, 0, 0);
    }
  },
});

const memory: WebAssembly.Memory = module.exports.memory;


function App() {
  let canvasRef!: HTMLCanvasElement;
  onMount(() => {
    canvas = canvasRef;
    let ctx = canvas.getContext("2d");
    if (ctx === null) throw new Error("2D context is null");
    screen = ctx;

    module.exports.randomScreen();
  });

  return (
    <div class="w-screen h-screen flex flex-col items-center gap-4">
      <div class="flex flex-col items-center p-4">
        <h1 class="text-6xl text-primary font-extrabold uppercase">TAMEBOY</h1>
        <p class="text-xl italic">Run GameBoy games in the browser using WASM</p>
      </div>
      <div class="flex items-center justify-center w-full h-full">
        <canvas ref={canvasRef} width={DisplayWidth} height={DisplayHeight} class="border-2 border-oxford-800" id="screen"></canvas>
      </div>
    </div>
  );
}

render(() => <App />, root!);
