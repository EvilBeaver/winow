
&Пластилин 
Перем Настройки;

&Пластилин 
Перем МенеджерСессий;

&Пластилин
&Табакерка
Перем ВходящийЗапрос;

&Пластилин
Перем ОбработчикЗапросов;

Перем ВебСервер;

&Желудь
Процедура ПриСозданииОбъекта()

КонецПроцедуры

Процедура Старт() Экспорт

	ЗапуститьСинхронно();
	
КонецПроцедуры

Процедура Стоп() Экспорт

	Если Не ВебСервер = Неопределено Тогда
		ВебСервер.Остановить();
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗапуститьСинхронно() Экспорт
	СоздатьСервер();
	ВебСервер.Запустить();
КонецПроцедуры

Функция ПолучитьНативныйСервер() Экспорт
	СоздатьСервер();
	Возврат ВебСервер;
КонецФункции

Процедура СоздатьСервер()
	Если ВебСервер = Неопределено Тогда
		ВебСервер = Новый ВебСервер(Настройки.Порт);
		ВебСервер.ДобавитьОбработчикЗапросов(ЭтотОбъект, "ОбработатьЗапрос");
	КонецЕсли;
КонецПроцедуры

Процедура ОбработатьЗапрос(Контекст, СледующийОбработчик) Экспорт // BSLLS:UnusedParameters-off

	Запрос = ЗапросИзКонтекста(Контекст);

	ОтветВино = ОбработчикЗапросов.СформироватьОтвет(Запрос);

	Ответ = ПодготовитьОтвет(ОтветВино);

	Заголовки = Ответ.ПолучитьЗаголовки();
	Куки = Ответ.ПолучитьКуки();

	Для Каждого Элемент Из Заголовки Цикл
		Контекст.Ответ.Заголовки[Элемент.Ключ] = Элемент.Значение;
	КонецЦикла;

	Для Каждого Кука Из Куки Цикл
		Контекст.Ответ.Куки.Добавить(Кука.Ключ, Кука.Значение.Значение, Кука.Значение.Параметры);
	КонецЦикла;

	Контекст.Ответ.КодСостояния = Ответ.ПолучитьКодСостояния();

	БуферДвоичныхДанных = Ответ.ПолучитьТело();

	Контекст.Ответ.Тело.Записать(БуферДвоичныхДанных, 0, БуферДвоичныхДанных.Размер);

КонецПроцедуры

Функция ПодготовитьОтвет(ОтветВино)
	Ответ = Новый ХттпОтвет;
	Ответ.КодСостояния(ОтветВино.СостояниеКод)
		 .Заголовки(ОтветВино.Заголовки)
		 .ТелоИзДвоичныхДанных(?(ОтветВино.ТелоДвоичныеДанные = Неопределено, 
		 	ПолучитьДвоичныеДанныеИзСтроки(ОтветВино.ТелоТекст),
			ОтветВино.ТелоДвоичныеДанные));

	Для Каждого Кука Из ОтветВино.Куки.Получить() Цикл
		ПараметрыКуки = Новый ПараметрыCookie;
		ПараметрыКуки.Путь = Кука.Значение.Путь;
		ПараметрыКуки.Истекает = Кука.Значение.ДатаИстечения;
		ПараметрыКуки.ТолькоHttp = Кука.Значение.ТолькоХттп;
		ПараметрыКуки.МаксимальныйВозраст = Кука.Значение.СрокЖизни;
		Ответ.Кука(Кука.Ключ, Кука.Значение.Значение, ПараметрыКуки);
	КонецЦикла;

	Возврат Ответ;
КонецФункции

Функция ЗапросИзКонтекста(Контекст)

	Запрос = ВходящийЗапрос.Достать();
	Запрос.Метод = Контекст.Запрос.Метод;
	Для Каждого Заголовок из Контекст.Запрос.Заголовки Цикл
		Запрос.Заголовки.Вставить(Заголовок.Ключ, Заголовок.Значение);
	КонецЦикла;
	Для Каждого Кука Из Контекст.Запрос.Куки Цикл
		Запрос.Куки.Добавить(Кука.Ключ, Кука.Значение);
	КонецЦикла;

	Запрос.Путь = РаскодироватьСтроку(Контекст.Запрос.Путь, СпособКодированияСтроки.КодировкаURL);
	Запрос.ПолныйПуть = Контекст.Запрос.Путь + РаскодироватьСтроку(Контекст.Запрос.СтрокаПараметров,СпособКодированияСтроки.КодировкаURL);
	Запрос.АдресУдаленногоУзла = Контекст.Соединение.УдаленныйIpАдрес;
	Запрос.ПортУдаленногоУзла = Контекст.Соединение.УдаленныйПорт;

	Если Контекст.Запрос.ЕстьФормыВТипеКонтента = Истина И
			СтрНачинаетсяС(НРег(Контекст.Запрос.ТипКонтента), "multipart/form-data") Тогда

		ДанныеФормы = Новый ДанныеСоставнойФормы();
		Для Каждого ЭлементФормы Из Контекст.Запрос.Форма Цикл
			Структура = Новый Структура("Метаданные, Значение", Новый Соответствие);
			Структура.Метаданные.Вставить("name", ОбернутьВСоответствие("name",ЭлементФормы.Ключ));
			Если ЭлементФормы.Значение.Количество() > 0 Тогда
				Структура.Значение = ПолучитьДвоичныеДанныеИзСтроки(ЭлементФормы.Значение[0]);
			КонецЕсли;
			ДанныеФормы.Добавить(Структура);
		КонецЦикла;

		Для Каждого ФайлФормы Из Контекст.Запрос.Форма.Файлы Цикл
			Структура = Новый Структура("Метаданные, Значение", Новый Соответствие);
			Структура.Метаданные.Вставить("ТипКонтента", ОбернутьВСоответствие("ТипКонтента",ФайлФормы.ТипКонтента));
			Структура.Метаданные.Вставить("РасположениеКонтента", ОбернутьВСоответствие("РасположениеКонтента",ФайлФормы.РасположениеКонтента));
			Структура.Метаданные.Вставить("name", ОбернутьВСоответствие("name",ФайлФормы.Имя));
			Структура.Метаданные.Вставить("filename", ОбернутьВСоответствие("filename",ФайлФормы.ИмяФайла));
			Заголовки = Новый Соответствие();
			Для Каждого Заголовок Из ФайлФормы.Заголовки Цикл
				Заголовки.Вставить(Заголовок.Ключ, Заголовок.Значение);
			КонецЦикла;
			Структура.Метаданные.Вставить("Заголовки", ОбернутьВСоответствие("Заголовки", Заголовки));

			Поток = ФайлФормы.ОткрытьПотокЧтения();

			ЧтениеДанных = Новый ЧтениеДанных(Поток);
			Структура.Значение = ЧтениеДанных.Прочитать().ПолучитьДвоичныеДанные();
			ДанныеФормы.Добавить(Структура);
		КонецЦикла;
		Запрос.УстановитьДанныеФормы(ДанныеФормы);
	Иначе

		ЧтениеДанных = Новый ЧтениеДанных(Контекст.Запрос.Тело);
		ДД = ЧтениеДанных.Прочитать().ПолучитьДвоичныеДанные();

		Запрос.ТелоДвоичныеДанные = ДД;
		Запрос.Тело = ПолучитьСтрокуИзДвоичныхДанных(Запрос.ТелоДвоичныеДанные);

	КонецЕсли;

	Запрос.Сессия = МенеджерСессий.ПолучитьСессиюПоКукам(Запрос.Куки);

	Для Каждого Параметр Из Контекст.Запрос.Параметры Цикл
		Запрос.ПараметрыИменные.Вставить(Параметр.Ключ, Параметр.Значение);
	КонецЦикла;

	Возврат Запрос;

КонецФункции

Функция ОбернутьВСоответствие(Ключ, Значение)
	Соответствие = Новый Соответствие();
	Соответствие.Вставить(Ключ, Значение);
	Возврат Соответствие;
КонецФункции;
