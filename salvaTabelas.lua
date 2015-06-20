salvaTabelas = {
	new =
		function ()

			local o = {}

			function o:gotDrop(v)
				pegouDrop = {}
				pegouDrop.x = v.x
				pegouDrop.y = v.y
				pegouDrop.tipo = v.tipo
				pegouDrop.a = 255
				table.insert(pegouDrops, pegouDrop)
			end

			function o:guardaBateu(v)
				bateu = {}
				bateu.x = nave.x
				bateu.y = nave.y
				bateu.a = 255
				table.insert(bateus, bateu)
			end

			function o:guardaPerdido(v)
				perdido = {}
				perdido.x = v.x
				perdido.y = screen_height - 50
				perdido.a = 255
				meteorosLost = meteorosLost + 1
				table.insert(perdidos, perdido)
			end

			function o:guardaAbatido(vv)
				acertou = {}
				acertou.x = vv.x
				acertou.y = vv.y
				acertou.a = 255
				table.insert(acertos, acertou)
			end

			return o;

		end
}
