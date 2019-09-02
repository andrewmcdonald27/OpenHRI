/*
 * Andrew McDonald
 * Michigan State University D-CYPHER Lab
 * Driver.h
 * 9.1.19
 * 
 * Provides functionality to execute 'turn and burst' commands using the MMEmotor library.
 */

#include "MMEmotor.h"
#include "Configuration.h"

#ifndef driver
#define driver

class Driver
{
private:
    MMEmotor &MotorA;
    MMEmotor &MotorB;
    Configuration Config;

public:
    Driver(MMEmotor &a, MMEmotor &b, Configuration &c) : MotorA(a), MotorB(b), Config(c){};

    // Purpose:     Stops robot's motion
    // Params:      none
    // Returns:     void
    void FullStop()
    {
        MotorA.brake();
        MotorB.brake();
    }

    // Purpose:     Turns robot 'deg' degrees, where CCW is a positive angle and CW is a negative angle
    // Params:      (int& deg) reference to int variable specifying rotation in degrees
    // Returns:     void
    void Turn(int &deg)
    {
        // experimentally determined constant to correlate delay with rotation in degrees
        int constant = 7;

        if (deg > 0)
        {
            // left turn (CCW = +)
            MotorA.backward(50);
            MotorB.forward(50);
            delay(abs(int(deg * constant)));
            FullStop();
        }
        else
        {
            // right turn (CW = -)
            MotorA.forward(50);
            MotorB.backward(50);
            delay(abs(int(deg * constant)));
            FullStop();
        }
    }

    // Purpose:     Accelerates robot into forward motion
    // Params:      (int& speed) Speed as integer percentage between 0-100 of full power
    // Returns:     void
    void Startup(int &speed)
    {
        for (int i = 0; i < speed; i++)
        {
            MotorA.backward(i);
            MotorB.backward(i);
            delay(Config.DelayAcceleration);
        }
    }

    // Purpose:     Decelerates robot from forward motion
    // Params:      (int& speed) Starting speed as integer percentage between 0-100 of full power
    // Returns:     void
    void Slowdown(int &speed)
    {
        for (int i = speed; i >= 0; i--)
        {
            MotorA.backward(i);
            MotorB.backward(i);
            delay(Config.DelayAcceleration);
        }
        FullStop();
    }

    // Purpose:     Bursts robot forward; called repeatedly along with Turn to converge on target point
    // Params:      (int& velocity) Speed as int percentage between 0-100 of full power
    // Returns:     void
    void Burst(int &velocity)
    {
        int speed = int(velocity);
        Startup(speed);
        Slowdown(speed);
    }

    // Purpose:     Turns and Bursts robot towards target point
    // Params:      (int &angle)      Angle in degrees as int; CCW is positive, CW is negative
    //              (int &velocity)   Speed as int percentage between 0-100 of full power
    // Returns:     void
    void Drive(int &angle, int &velocity)
    {
        Turn(angle);
        Burst(velocity);
    }
};

#endif