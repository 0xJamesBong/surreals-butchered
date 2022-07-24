

numbersAlreadyCreated = [0, 1, 3, 5,7,8,11,17,18,19,37,55,57,59,77, 80]

def largestNumberSmallerThan(listofNumbers:list, x: int):
    
    length = len(listofNumbers)
    middle = length // 2 
    
    firstHalf = listofNumbers[0:middle] 
    print(firstHalf)
    secondHalf = listofNumbers[middle:]
    listmax = max(listofNumbers)
    maxFH = max(firstHalf)
    minSF = min(secondHalf)
    print(maxFH, x, minSF)
    if listmax <= x:
        print(f'the number is {listmax}')
        return listmax
    elif (maxFH <= x and x <= minSF):
        print(f'the number is {maxFH}')
        return maxFH

    elif maxFH < x and minSF < x: 
        largestNumberSmallerThan(secondHalf, x)
    elif x < maxFH:
        largestNumberSmallerThan(firstHalf, x)
    
         
    
        
    
        
    
    # largestNumberSmallerThan = firstHalf[0]
    # while largestNumberSmallerThan != 
    # if firstHalf[0] > n:
    #     print("not here, in second half")
    # else: 
    #     print("in this half, try something bigger")
    # # print(firstHalf)
    # # print(secondHalf)
    # # print("in first half ") if n in firstHalf else print("in second half") if n in secondHalf  else print("nowhere")
    
    
largestNumberSmallerThan(numbersAlreadyCreated, x=6)
# largestNumberSmallerThan(numbersAlreadyCreated, x=0)