#include <msp430.h> // Port definitions, etc.

// Main routine
int main(void) {
    WDTCTL = WDTPW + WDTHOLD; // Stop Watchdog Timer
    P1SEL &= ~BIT0;           // Pin 1.0 as I/O
    P1DIR |=  BIT0;           // Pin 1.0 as output
    P1OUT |=  BIT0;           // Pin 1.0 high
    LPM3;                     // Low power mode
    return 0;
}
