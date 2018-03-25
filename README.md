# Searching tickets keywords recognition in speech

Swift project of getting user voice and parse it on keywords using [Dialogflow](https://dialogflow.com) for searching air-tickets. 

## Using

Application recognise two types of searching phrases: by from/to points of trip and by flight number and date. 

### Example
![](https://media.giphy.com/media/8mqypqR38X5QQr8Cvt/giphy.gif)

```
Найди мне билеты из Москвы в Париж на завтра
```

Result:
```
@from: Москва
@to: Париж
@date: 20.07.17
```

![](https://media.giphy.com/media/vbR3jW0mErk0QJtXxk/giphy.gif)

```
Мне нужен билеты на рейс SU 1452 на 26 июля
```

Result:
```
@number: 1452
@airlines: S7
@date: 26.07.17
```
