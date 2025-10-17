class_name Party
var members =[]
var name =""
func addtoparty(adventurer):
	if len(members)<5:
		members.append(adventurer)

func getadventurer(index):
	return members.get(index)
	
func IsFull ():
	return len(members)>=5
	
