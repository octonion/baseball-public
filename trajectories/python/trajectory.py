from ctypes import *
import os

lib = cdll.LoadLibrary(os.path.abspath("libtrajectory.so"))
lib.trajectory_.argtypes = [
    POINTER(c_float),POINTER(c_float),POINTER(c_float),
    POINTER(c_float),POINTER(c_float),POINTER(c_float),
    POINTER(c_float),POINTER(c_float),POINTER(c_float),
    POINTER(c_float),POINTER(c_float),POINTER(c_float),
    POINTER(c_float),POINTER(c_float),POINTER(c_float)
]

def trajectory(cd0,cddot,cdspin,w0,theta0,tau0,rhodata,vdata,thetadata,vwind):

    cd0 = c_float(cd0)
    cddot = c_float(cddot)
    cdspin = c_float(cdspin)
    w0 = c_float(w0)
    theta0 = c_float(theta0)
    tau0 = c_float(tau0)

    rhodata = c_float(rhodata)
    vdata = c_float(vdata)
    thetadata = c_float(thetadata)
    vwind = c_float(vwind)

    spin_rpm = c_float(0.0)
    sfact = c_float(0.0)
    cdi = c_float(0.0)
    distance = c_float(0.0)
    tof = c_float(0.0)

    lib.trajectory_(
        byref(cd0),byref(cddot),byref(cdspin),
        byref(w0),byref(theta0),byref(tau0),
        byref(rhodata),byref(vdata),byref(thetadata),byref(vwind),
        byref(spin_rpm),byref(sfact),byref(cdi),byref(distance),byref(tof))

    return spin_rpm.value, sfact.value, cdi.value, distance.value, tof.value

# Example from Alan's parameters.csv

cd0 = 0.4103
cddot = 0.0044
cdspin = 0.2043
w0 = 2069.4111
theta0 = 7.2023
tau0 = 25.0000

# Example from Alan's trajectory_input.csv

rhodata = 1.19
vdata = 91.0
thetadata = 27.5
vwind = 2.0

# These values are returned

spin_rpm,sfact,cdi,distance,tof = trajectory(
    cd0,cddot,cdspin,w0,theta0,tau0,
    rhodata,vdata,thetadata,vwind)

print("distance = ",distance,", time-of-flight = ",tof)
