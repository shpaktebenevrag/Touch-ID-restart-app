# Установка Restart Touch ID на новый Mac

Краткая инструкция: поставить приложение и настроить перезапуск Touch ID **без запроса пароля при каждом запуске**.

## 1. Скопировать проект на Mac

Папку `restart-touchid` перенесите любым способом (AirDrop, флешка, git, архив). Пример пути:

```text
~/Projects/restart-touchid
```

## 2. Собрать и установить приложение

```bash
cd ~/Projects/restart-touchid
chmod +x build-app.sh restart-touchid.sh install-helper.sh
./build-app.sh
cp -R "Restart Touch ID.app" ~/Applications/
```

После этого приложение можно запускать из **Программы** / Launchpad.  
Пароль администратора **не спрашивается** — выполняется только пользовательский перезапуск UI Touch ID.

## 3. Полный перезапуск без пароля (один раз на этом Mac)

Чтобы при каждом клике перезапускались системные службы (`biometrickitd`), один раз выполните (пароль понадобится **только здесь**):

```bash
cd ~/Projects/restart-touchid
./install-helper.sh
```

Скрипт установит:

- `/usr/local/bin/restart-touchid-system`
- правило в `/etc/sudoers.d/restart-touchid` (только эта команда, без полного sudo)

Проверка без диалога пароля:

```bash
sudo -n /usr/local/bin/restart-touchid-system soft && echo OK
```

Если выводится `OK`, приложение при запуске тоже не будет спрашивать пароль.

## 4. Первый запуск .app

macOS может показать предупреждение об «неизвестном разработчике»:

**Системные настройки → Конфиденциальность и безопасность → Всё равно открыть**

или ПКМ по приложению → **Открыть**.

## Обновление после правок в проекте

```bash
cd ~/Projects/restart-touchid
./build-app.sh
cp -R "Restart Touch ID.app" ~/Applications/
```

Если менялся только системный helper:

```bash
./install-helper.sh
```

## Удаление

```bash
rm -rf ~/Applications/Restart\ Touch\ ID.app
sudo rm -f /usr/local/bin/restart-touchid-system /etc/sudoers.d/restart-touchid
```

## Команды из терминала (необязательно)

```bash
cd ~/Projects/restart-touchid
./restart-touchid.sh              # без пароля (как .app)
./restart-touchid.sh system       # полный перезапуск (sudo, если helper не установлен)
./restart-touchid.sh --full-reset # жёсткий сброс отпечатков (sudo, заново добавить в Touch ID)
```
