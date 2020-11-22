extends Control

#variables modificables
var recursosXciudadano
var produccionXciudadanoCoef
var eficienciaMax

#variables grobales
var ciudadanoCount
var stepsCount
var recursos
var recolectado
var eficienciaArray
var running
var rnd = RandomNumberGenerator.new()  

#gestion de crisis de recursos
var crisisCountMax
var crisisCount
var crisisCount2Max
var crisisCount2
var crisisBool
var caidaRecursosCoef

#variables para el grafico
var anchoGrafico= 300
var altoGrafico= 200

func _ready():
	rnd.randomize()
	#create ciudadanos
	recursosXciudadano= get_node("PopupMenu/HBoxContainer/recursosXCiud").value
	produccionXciudadanoCoef= get_node("PopupMenu/HBoxContainer2/produccionXCiud").value
	eficienciaMax= recursosXciudadano * produccionXciudadanoCoef
	
	_calcula_CiudadanosCount()
	
	eficienciaArray= Array()
	for i in range(ciudadanoCount):
		eficienciaArray.append(eficienciaMax)
		
	crisisCount= 0
	crisisCountMax= get_node("PopupMenu/HBoxContainer/periodoEntreCrisis").value
	crisisCount2= 0
	crisisCount2Max= get_node("PopupMenu/HBoxContainer/periodoDeCrisis").value
	crisisBool= true
	caidaRecursosCoef= get_node("PopupMenu/HBoxContainer2/decaidaRecursos").value
	
	running= false
	
	_spawn()
	_resetGrafico()

func _process(delta):
	if running:
		_step()
		stepsCount+= 1
		get_node("VBoxContainer/Label").text= "Steps : " + str(stepsCount)
		_drawGrafico()
		

func _drawGrafico():
	var recur= get_node("VBoxContainer2/recursos").value
	var recol= get_node("VBoxContainer2/recolectado").value
	var efic= get_node("VBoxContainer2/eficiencia").value
	
	recur= int(altoGrafico - ((recur * 0.01) * altoGrafico))
	recol= int(altoGrafico - ((recol * 0.01) * altoGrafico))
	efic= int(altoGrafico - ((efic * 0.01) * altoGrafico))
	
	get_node("Grafico/lineRecursos").add_point(Vector2(anchoGrafico,recur))
	get_node("Grafico/lineRecolectado").add_point(Vector2(anchoGrafico,recol))
	get_node("Grafico/lineEficiencia").add_point(Vector2(anchoGrafico,efic))
	
	if get_node("Grafico/lineRecursos").get_point_count() > anchoGrafico:
		var delete= get_node("Grafico/lineRecursos").get_point_count() - anchoGrafico
		for i in range(delete):
			get_node("Grafico/lineRecursos").remove_point(0)
			get_node("Grafico/lineRecolectado").remove_point(0)
			get_node("Grafico/lineEficiencia").remove_point(0)
	
	var pasos= int(anchoGrafico / get_node("Grafico/lineRecursos").get_point_count())
	
	for i in range(get_node("Grafico/lineRecursos").get_point_count()):
		var aux1= get_node("Grafico/lineRecursos").get_point_position(i).y
		var aux2= get_node("Grafico/lineRecolectado").get_point_position(i).y
		var aux3= get_node("Grafico/lineEficiencia").get_point_position(i).y
		
		get_node("Grafico/lineRecursos").set_point_position(i,Vector2(pasos * i,aux1))
		get_node("Grafico/lineRecolectado").set_point_position(i,Vector2(pasos * i,aux2))
		get_node("Grafico/lineEficiencia").set_point_position(i,Vector2(pasos * i,aux3))
	
func _resetGrafico():
	get_node("Grafico/lineRecursos").clear_points()
	get_node("Grafico/lineRecolectado").clear_points()
	get_node("Grafico/lineEficiencia").clear_points()
	
	get_node("Grafico/lineRecursos").add_point(Vector2(0,0))
	get_node("Grafico/lineRecolectado").add_point(Vector2(0,0))
	get_node("Grafico/lineEficiencia").add_point(Vector2(0,0))
	

func _step():
	
	var array = Array()
	ciudadanoCount= get_node("folder").get_child_count()
	recursos= ciudadanoCount * eficienciaMax
	var rectotal= recursos
	
	if crisisCount < crisisCountMax:
		crisisCount+= 1
	else:
		if crisisBool:
			if crisisCount2 < crisisCount2Max:
				crisisCount2+= 1
			else:
				crisisBool= false
		else:
			if crisisCount2 > 0:
				crisisCount2-= 1
			else:
				crisisCount2= 0
				crisisCount= 0
				crisisBool= true
			
		if crisisCount2 * crisisCount2Max > 0:
			var caida= recursos * caidaRecursosCoef
			recursos-= ((crisisCount2 / crisisCount2Max) * caida)
	
	
	var recVariable= recursos
	var nuevarecolecta= 0
	var eficienciaMedia= 0
	#print("rectotal= ",rectotal," recursos= ",recursos)
	for count in range(ciudadanoCount):
		var ciudadano
		var found= true
		
		while found:
			var rand = rnd.randi_range(0,ciudadanoCount - 1)
			found= array.has(rand)
			if !found: 
				ciudadano = rand
				array.append(ciudadano)
		
		#primero come luego recolecta
		if recolectado >= recursosXciudadano:
			recolectado-= recursosXciudadano
			#recuperacion segun eficiencia solo si come a tope
			var value= get_node("PopupMenu/HBoxContainer2/tasaRecuperacion").value
			if value > 0:
				eficienciaArray[ciudadano]+= (eficienciaArray[ciudadano] * value)
				if eficienciaArray[ciudadano] > eficienciaMax:
					eficienciaArray[ciudadano]= eficienciaMax
				var aux= (eficienciaArray[ciudadano] / (eficienciaMax)) * 255
				value= Color8(255 - aux,aux,0,180)
				get_node("folder").get_child(ciudadano).get_node("Sprite").set_modulate(value)
				
		else:
			var consume= recolectado
			if consume <= 0: consume= 1
			
			recolectado-= consume
			
			if eficienciaArray[ciudadano] > consume * produccionXciudadanoCoef:
				eficienciaArray[ciudadano]= consume * produccionXciudadanoCoef
			
			var aux= (eficienciaArray[ciudadano] / (eficienciaMax)) * 255
			var value= Color8(255 - aux,aux,0,180)
			get_node("folder").get_child(ciudadano).get_node("Sprite").set_modulate(value)
		
		#recolecta
		if recursos > eficienciaArray[ciudadano]:
			nuevarecolecta+= eficienciaArray[ciudadano]
			recursos-= eficienciaArray[ciudadano]
			#riesgo lesion solo si trabaja a tope
			var value= get_node("PopupMenu/HBoxContainer2/riesgoLesion").value
			if value > 0:
				if eficienciaArray[ciudadano] > 1:
					var rand = rnd.randf_range(0,1)
					if rand < value:
						eficienciaArray[ciudadano]*= rnd.randf_range(0.1,1)
						var aux= (eficienciaArray[ciudadano] / (eficienciaMax)) * 255
						value= Color8(255 - aux,aux,0,180)
						get_node("folder").get_child(ciudadano).get_node("Sprite").set_modulate(value)
		else:
			nuevarecolecta+= recursos
			recursos= 0
			
		
		eficienciaMedia+= eficienciaArray[ciudadano]
	
	if eficienciaMedia * ciudadanoCount > 0:
		eficienciaMedia/= ciudadanoCount
		
	recolectado= nuevarecolecta
	if recursos <= 0: recursos= 1
	if recolectado <= 0: recolectado= 1
	
	get_node("VBoxContainer2/recursos").value= (recVariable / rectotal) * 100
	get_node("VBoxContainer2/recolectado").value= (recolectado / rectotal) * 100
	get_node("VBoxContainer2/eficiencia").value= (eficienciaMedia / (eficienciaMax)) * 100
	
	if ciudadanoCount == 0 || get_node("VBoxContainer2/eficiencia").value < 1.5:
		running= false
	

func _spawn():
	for n in get_node("folder").get_children():
		get_node("folder").remove_child(n)
		n.queue_free()
	
	var lados= Vector2(56,get_node("HBoxContainer/Poblacion").value)
	var dimensionsVector= Vector2(8,8)
	
	var scene
	if get_node("Estilos").selected == 0:
		scene = load("res://ciudadano.tscn")
		get_node("Sistemas").visible= false
	elif get_node("Estilos").selected == 1:
		scene = load("res://ciudadano.tscn")
		lados.x= 55
		get_node("Sistemas").visible= true
	else:
		scene = load("res://body-vacio.tscn")
		lados.x= 41
		dimensionsVector.x= 11
		dimensionsVector.y= 24
		get_node("Sistemas").visible= false
	
	for n in range(lados.x):
		if get_node("Estilos").selected !=1 || n%9 != 0:
			for n2 in range(lados.y):
				var instance = scene.instance()
				
				var x= 20 + (n * dimensionsVector.x * 1.5)
				var y= 580 - (n2 * dimensionsVector.y * 1.5)
				instance.set_global_position(Vector2(x,y))
				get_node("folder").add_child(instance)
	
	stepsCount= 0
	get_node("VBoxContainer/Label").text= "Steps : 0"
	
	recolectado= ciudadanoCount * recursosXciudadano
	for i in range(eficienciaArray.size()):
		eficienciaArray[i]= eficienciaMax
		
	
func _calcula_CiudadanosCount():
	var capas= get_node("HBoxContainer/Poblacion").value
	if get_node("Estilos").selected == 0:
		if capas > 43:
			capas= 43
			get_node("HBoxContainer/Poblacion").value= capas
		ciudadanoCount= capas * 56
		get_node("TotalPoblacion").text= str(capas," x 56 = ",ciudadanoCount)
	elif get_node("Estilos").selected == 1:
		if capas > 43:
			capas= 43
			get_node("HBoxContainer/Poblacion").value= capas
		ciudadanoCount= capas * 48
		get_node("TotalPoblacion").text= str(capas," x 48 = ",ciudadanoCount)
	else:
		if capas > 15:
			capas= 15
			get_node("HBoxContainer/Poblacion").value= capas
		ciudadanoCount= capas * 41
		get_node("TotalPoblacion").text= str(capas," x 41 = ",ciudadanoCount)

func _on_Play_pressed():
	running= true

func _on_Pause_pressed():
	running= false

func _on_Reset_pressed():
	running= false
	_calcula_CiudadanosCount()
	_spawn()
	_resetGrafico()
	crisisCount= 0
	crisisCount2= 0
	crisisBool= true

func _on_recursosXCiud_value_changed(value):
	var antiguoEstado= running
	running= false
	var antiguaEficienciaMax= eficienciaMax
	recursosXciudadano= get_node("PopupMenu/HBoxContainer/recursosXCiud").value
	var nuevaEficienciaMax= recursosXciudadano * produccionXciudadanoCoef
	
	_calcula_CiudadanosCount()
	
	for i in range(ciudadanoCount):
		var aux= (eficienciaArray[i] / antiguaEficienciaMax)
		aux*= nuevaEficienciaMax
		eficienciaArray[i]= aux
		
	eficienciaMax= nuevaEficienciaMax
	running= antiguoEstado

func _on_produccionXCiud_value_changed(value):
	var antiguoEstado= running
	running= false
	var antiguaEficienciaMax= eficienciaMax
	produccionXciudadanoCoef= get_node("PopupMenu/HBoxContainer2/produccionXCiud").value
	var nuevaEficienciaMax= recursosXciudadano * produccionXciudadanoCoef
	
	_calcula_CiudadanosCount()
	
	for i in range(ciudadanoCount):
		var aux= (eficienciaArray[i] / antiguaEficienciaMax)
		aux*= nuevaEficienciaMax
		eficienciaArray[i]= aux
		
	eficienciaMax= nuevaEficienciaMax
	running= antiguoEstado

func _on_Poblacion_value_changed(value):
	running= false
	
	_calcula_CiudadanosCount()
	
	for i in range(ciudadanoCount):
		eficienciaArray.append(eficienciaMax)
	_spawn()
	_resetGrafico()
	crisisCount= 0
	crisisCount2= 0
	crisisBool= true


func _on_periodoEntreCrisis_value_changed(value):
	crisisCountMax= value


func _on_periodoDeCrisis_value_changed(value):
	crisisCount2Max= value


func _on_decaidaRecursos_value_changed(value):
	caidaRecursosCoef= value
