&Пластилин
Перем ОбщийКонтейнер Экспорт;

&Контроллер("/demoviews")
&Желудь
Процедура ПриСозданииОбъекта()

КонецПроцедуры

&Отображение("./example/hwapp/view/view1.html")
&ТочкаМаршрута("demo1")
Процедура ДемонстрацияОтображения(ВходящийЗапрос, Ответ, Сессия) Экспорт

	Ответ.УстановитьТипКонтента("html");

	ГСЧ = Новый ГенераторСлучайныхЧисел();
	
	СлучайноеЧисло = ГСЧ.СлучайноеЧисло(1, 10);

	Массив = Новый Массив();

	Для Сч = 1 по СлучайноеЧисло Цикл
		Массив.Добавить(Строка(Новый УникальныйИдентификатор()));
	КонецЦикла;

	Модель = Новый Структура();
	Модель.Вставить("СлучайноеЧисло", СлучайноеЧисло);
	Модель.Вставить("МассивСтрок", Массив);

	МассивФруктов = Новый Массив();
	МассивФруктов.Добавить("Яблоко");
	МассивФруктов.Добавить("Апельсин");
	МассивФруктов.Добавить("Банан");
	МассивФруктов.Добавить("Желудь");

	Модель.Вставить("ВторойМассив", МассивФруктов);

	Ответ.Модель = Модель;

КонецПроцедуры