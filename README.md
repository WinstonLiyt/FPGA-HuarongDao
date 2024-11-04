# FPGA-HuarongDao

## Introduction

This comprehensive experiment is an **FPGA-based digital Huarong Dao (Chinese sliding block puzzle) mini-game** using **VS1003B-MP3**, **COMPRQ keyboard**, and **VGA display**. The project involves a digital Huarong Dao game interface on a VGA display, including three game levels (`easy`,` medium`, `hard`) and a `test` level. Each level is accompanied by a classical background music piece. Users can select the number block they wish to move via the COMPRQ keyboard input and choose the direction of movement using the direction keys on the NEXYS4 development board. The chosen scheme will be displayed on the **VGA screen**, while the number of moves will be displayed on the **seven-segment digital tube** of the NEXYS4 development board.

## Programming languages

-   **Verilog**
-   **C++** (as scripting languages)
-   **MATLAB** (as scripting languages)

### Development environment

-   **Vivado 2016.2**
-   **Visual Studio Code**

## Equipment Introduction

-   **NEXYS4 DDR Development Board:** A versatile field-programmable gate array development board developed by Xilinx's Digilent.
-   **VGA Display:** VGA interface with a resolution of 640 x 480, a refresh rate of 60hz, and a corresponding clock frequency of 25Mhz.
-   **VS1003B-MP3:** Capable of playing audio with WMA 4.0/4.1/7/8/9 5-384kbps all stream files, MP3, and WAV streams.
-   **COMPRQ Keyboard:** A standard keyboard (PS/2) produced by Compaq, USB interface, wired.

## Architecture Diagram
![image](https://github.com/user-attachments/assets/6cd213bd-f111-4566-a720-c0fe1ffdb762)
![image](https://github.com/user-attachments/assets/65936af6-766c-40eb-b290-ff14425c3c7d)


## Game Instruction

After connecting the **VS1003B-MP3**, **COMPRQ keyboard**, and **VGA display** to the *NEXYS4 development board* and burning the `GAME_TOP .bit` file into the development board, set the `J15` pin to $1$ to enter the game. After selecting the game level (`difficulty`) with the `H6` and `T13` pins, press the `N17` pin of the development board to initialize the game. Then, you can choose the number block you want to move from $1-8$ on the keyboard and select the direction of the number block movement by pressing the four direction keys (up, right, down, left) `M18`, `M17`, `P18`, `P17` on the development board. If the current number block cannot move, the game's step count will not increase; if the current number block moves, the game's step count increases. During this process, the user's selected number and direction will be displayed on the **VGA display**, and the user's step count will be displayed on the *development board's digital tube*. If the game is successfully cleared, the words "Congratulations" will appear in the lower right corner of the **VGA display**, the outer frame of the Huarong Road will change from red to green, and the `K15` LED light on the development board will light up. In addition, during the game, you can perform resets and switch levels at any time (also by pressing the `N17` button). Lift the `U18` pin of the development board upwards, and the background music corresponding to each level will play. If you want to replay the music from the beginning, you can set the `U18` pin of the development board to $0$ and then to $1$.

## Rendering
![image](https://github.com/WinstonLiyt/FPGA-HuarongDao/assets/104308117/9c462301-b834-4eb5-a2e3-3c23dcfae17b)
