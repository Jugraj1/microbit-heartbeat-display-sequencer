# microbit‑heartbeat‑display‑sequencer ❤️‍🔥  
COMP2300 Assignment 2 · 2024/25

An ARMv6‑M assembly program that turns the BBC micro:bit V2 into an interactive heartbeat monitor:

* Three‑phase LED animation (small → partial → full heart)  
* **Dynamic tempo & brightness** controlled by Buttons A & B  
* Graceful “heart‑failure” mode when limits are exceeded  
* Sliding graph that explains why the failure occurred  
* Fully modular, register‑compliant, and heavily commented

> **Course** : Australian National University – COMP2300  
> **Author**  : Jugraj Singh (@Jugraj1)

---

## 1. Project Highlights

| File / Dir | Purpose |
|------------|---------|
| `src/main.S` | Program entry, reset vector, syscall stubs |
| `src/heartbeat.S` | Core animation loop (3 heart phases) |
| `src/buttons.S` | Debounced input handling for Buttons A/B |
| `src/brightness.S` | Global brightness table & fade helpers |
| `src/images.S` | 5×5 LED bitmaps (hearts, graph frames) |
| `src/failure_graph.S` | Sliding graph & LED mask logic |
| `linker.ld` | Bare‑metal scatter‑loading script |
| `Makefile` | Build → link → UF2 conversion workflow |
| `docs/` | Diagrams, timing tables, demo GIFs |
| `report.md` | Design/analysis report submitted for marking |

### Key Features
* **Three brightness tiers** (low/medium/high) with smooth PWM‑style fades  
* **Tempo scaling** tied directly to brightness—press **B** to speed up & brighten, **A** to slow down & dim  
* **Fail‑safe lockout** when brightness or tempo exceeds safe bounds; outer LEDs fade to illustrate cardiac arrest  
* **Monitor graph** animates across the matrix to flag whether over‑activity or under‑activity caused the failure  
* **Zero unnecessary PUSH/POP** – optimised for minimal stack churn and fast ISR return

---

## 2. Demo

![heartbeat gif](docs/heartbeat_demo.gif)  
*(replace with your actual GIF or MP4)*

---

## 3. Getting Started

### Hardware
* BBC micro:bit **V2** (runs on V1 too, but brightness PWM looks smoother on V2)
* Micro‑USB cable

### Software
* `arm-none-eabi-gcc` 10+  
* `uf2conv.py` (comes with official microbit‑tools)  
* `make`

### Build & Flash
```bash
# Clone the repo
git clone https://github.com/Jugraj1/microbit-heartbeat-display-sequencer.git
cd microbit-heartbeat-display-sequencer

# Produce build/main.uf2
make

# Plug in the micro:bit and copy the UF2
cp build/main.uf2 /Volumes/MICROBIT/
#   or drag‑and‑drop on Windows
