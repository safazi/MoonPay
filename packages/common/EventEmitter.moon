-- EventEmitter.moon

class EventEmitter
	new:=>@A={}
	create:(A,B,C)=>table.insert @A,:A,:B,:C
	on:(A,B)=>@create A,B
	once:(A,B)=>@create A,B,true
	emit:(A,...)=>
		B=[{:C,:D}for C,D in pairs @A when D.A==A and D.B]
		return if #B == 0
		E,F=0,{}
		for G in*B
			H=G.D.B ...
			table.insert F,H if H~=nil
			if G.D.C
				table.remove @A,G.C-E
				E+=1
		(#F>1 and F)or F[1]
