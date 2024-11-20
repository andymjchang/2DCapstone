inp = open("CustomLevel.dat", "r")
out = open("output2.txt", "a")

AMOUNT = -25

for line in inp.readlines():
    splitLine = line.split(", ")
    print("Splitted: ", splitLine)
    if len(splitLine) > 4:
        newX = int(splitLine[0].strip()) + AMOUNT
        shiftedLine = str(newX) + ", " + splitLine[1] + ", " + splitLine[2] + ", " + splitLine[3] + ", " + splitLine[4]
        out.write(shiftedLine)
    elif len(splitLine) == 3:
        newX = int(splitLine[0].strip()) + AMOUNT
        shiftedLine = str(newX) + ", " + splitLine[1] + ", " + splitLine[2]
        out.write(shiftedLine)
    elif len(splitLine) == 2:
        newX = int(float(splitLine[0].strip().strip(", "))) + AMOUNT
        shiftedLine = str(newX) + ", " + splitLine[1]
        out.write(shiftedLine)
    elif len(splitLine) == 1:
        out.write(splitLine[0].strip() + "\n")
out.close()
inp.close()
