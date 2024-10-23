

inp = open("Lvl1.4.1.dat", "r")
out = open("output.txt", "a")

AMOUNT = -500

for line in inp.readlines():
    splitLine = line.split(", ")
    print("Splitted: ", splitLine)
    if len(splitLine) > 4:
        newY = int(splitLine[1].strip()) + AMOUNT
        shiftedLine = splitLine[0] + ", " + str(newY) + ", " + splitLine[2] + ", " + splitLine[3] + ", " + splitLine[4]
        out.write(shiftedLine)
    elif len(splitLine) == 2:
        newY = int(float(splitLine[1].strip().strip(", "))) + AMOUNT
        shiftedLine = splitLine[0] + ", " + str(newY) + ", \n"
        out.write(shiftedLine)
    elif len(splitLine) == 1:
        out.write(splitLine[0].strip() + "\n")
out.close()
inp.close()
