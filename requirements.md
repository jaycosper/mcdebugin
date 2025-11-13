# Project _McDebugin_
A simple, hand-held modern stand-alone alternative to the venerable Fluke 9010A Micro-System Troubleshooter. Focus is on easy to understand user interface and common test features, but not a full-fledged replacement product.

Device should be as easy to use as a DMM.

# Requirements

## Physical Dimensions
| Specification | Value | Notes |
|----------|-------------|------|
| Product | Approximately 4"W x 10"L x 2"T| - |
| Pod | Approximately 3"W x 1"L| - |
| Display | Less than 3" |https://www.adafruit.com/product/4694 https://www.adafruit.com/product/2674 https://www.adafruit.com/product/1774 https://www.adafruit.com/product/198 |

## Interfaces
| Specification | Value | Notes |
|----------|-------------|------|
| Power | DC Input < 10W, power switch, indicator | Battery optional |
| SD Card | Size TBD | Minimum size for programming file |
| Keypad | Numbers 0x0-0xF, _enter_ key, 4+ Function | mechanical preferred |
| Probe | Standard bayonet coax | oscilloscope compatible |
| CPU Connection | Depends on TBD Pod architecture | 6-40 connections |
| LEDs | General Use | Minimum 4: unit power, target power, SD access, target clock lock |

###  Keypad Layout
_Traditional_

16 keys
| | | | |
|-|-|-|-|
| C | D | E | F |
| 8 | 9 | A | B |
| 4 | 5 | 6 | 7 |
| 0 | 1 | 2 | 3 |

_Numpad style_

25 keys
| F1 | F2 | F3 | F4 |
|-|-|-|-|
| D | E | F | a0 |
| A | B | C | a1 |
| 7 | 8 | 9 | a2 |
| 4 | 5 | 6 | a3 |
| 1 | 2 | 3 | a4 |
| 0 | | ESC | a5 |

zero key is double

a3 - a5 => ENTER

a0 - a2 => single keys; CLEAR, STATUS/CONTROL, MORE, RUN, STOP

## Pod
| Specification | Value | Notes |
|----------|-------------|------|
| Target Board Connection | machined headers, requires socket on target board | - |
| Supported CPUs | Z80, 6502, 6809 (40-pin DIP) | Other pinouts possible |
| Supported Clock Rates | < 20MHz | - |
| Bidirectional Pins | All IO pins | 8-bit bus typical |

## Features
| Specification | Value | Notes |
|----------|-------------|------|
| Clock detection | Detects clock from target board and reports frequency/variation | - |
| TBD | TBD | - |
| TBD | TBD | - |
| TBD | TBD | - |
| TBD | TBD | - |
| TBD | TBD | - |

## Tests
- Clock Frequency
    - detect and report frequency
- RAM
    - short test
    - long test
    - user specified range
    - sub-tests
        - walking 0's
        - walking 1's
        - random write/read
    - report failures/mismatches
    - loop test
- ROM
    - read and calculate CRC32
    - user specified range
- Signal Analysis with Probe
    - TBD
- Status
    - Display live status of pins
        - interrupt / NMI
        - reset
