## GIT 分支

 首次提交产生的提交对象没有父对象，普通提交操作产生的提交对象有一个父对象， 而由多个分支合并产生的提交对象有多个父对象， 暂存操作会为每一个文件计算校验和，然后会把当前版本的文件快照保存到 Git 仓库中 （Git 使用 *blob* 对象来保存它们），最终将校验和加入到暂存区域等待提交。

当使用 `git commit` 进行提交操作时，Git 会先计算每一个子目录的校验和，然后在 Git 仓库中这些校验和保存为树对象。随后，Git 便会创建一个提交对象， 它除了包含上面提到的那些信息外，还包含指向这个树对象（项目根目录）的指针。 如此一来，Git 就可以在需要的时候重现此次保存的快照。

现在，Git 仓库中有五个对象：三个 *blob* 对象（保存着文件快照）、一个 **树** 对象 （记录着目录结构和 blob 对象索引）以及一个 **提交** 对象（包含着指向前述树对象的指针和所有提交信息）。

![image-20211012142108692](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012142108692.png)

做些修改后再次提交，那么这次产生的提交对象会包含一个指向上次提交对象（父对象）的指针。

做些修改后再次提交，那么这次产生的提交对象会包含一个指向上次提交对象（父对象）的指针。

![image-20211012142417720](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012142417720.png)



Git 的分支，其实本质上仅仅是指向提交对象的可变指针。 Git 的默认分支名字是 `master`。 在多次提交操作之后，其实已经有一个指向最后那个提交对象的 `master` 分支。 `master` 分支会在每次提交时自动向前移动。

> Git 的 `master` 分支并不是一个特殊分支。 它就跟其它分支完全没有区别。 之所以几乎每一个仓库都有 master 分支，是因为 `git init` 命令默认创建它，并且大多数人都懒得去改动它。

#### 创建分支

git创建分支，只是创建一个可以移动的指针，`git branch`  会在所提交的对象上创建一个指针

```bash
git branch  name 
```

![image-20211012143053639](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012143053639.png)



 在 Git 中有一个指针名为`head`，指向当前所在的本地分支（将 `HEAD` 想象为当前分支的别名）。  `git branch` 命令仅仅 **创建** 一个新分支，并不会自动切换到新分支中去。

使用 `git log ` 命令查看各个分支当前所指的对象  

```shell
git log  --oneline --decorate

f30ab (HEAD -> master, testing) add feature #32 - ability to add new formats to the central interface
34ac2 Fixed bug #1328 - stack overflow under certain conditions
98ca9 The initial commit of my project
```

#### 分支切换

要切换到一个已存在的分支，使用 `git checkout` 命令。

```shell
git checkout name
```

![image-20211012143518466](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012143518466.png)

如此 head指针边切换至testing上

然后提交一次

```shell
git commit -m 'check out to testing'
```

![image-20211012143829379](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012143829379.png)

之后 testing 分支则向前移动，而master则没有，它仍然指向运行 `git checkout` 时所指的对象。

当切换到master分支时，工作目录则恢复至master分支所指的快照内容，质上来讲，这就是忽略 `testing` 分支所做的修改，以便于向另一个方向进行开发。

> 在切换分支时，一定要注意你工作目录里的文件会被改变。 如果是切换到一个较旧的分支，你的工作目录会恢复到该分支最后一次提交时的样子。 如果 Git 不能干净利落地完成这个任务，它将禁止切换分支。

当修改master分支的项目，然后提交一次之后，项目此时成为了另一种形式

![image-20211012144256099](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012144256099.png)

可以在不同分支间不断地来回切换和工作，并在时机成熟时将它们合并起来。 而所有这些工作，需要的命令只有 `branch`、`checkout` 和 `commit`。

使用 `git log` 命令查看分叉历史。 运行 `git log --oneline --decorate --graph --all` ，它会输出你的提交历史、各个分支的指向以及项目的分支分叉情况。

```shell
git log --oneline  --decorate --graph --all

* c2b9e (HEAD, master) made other changes
| * 87ab2 (testing) made a change
|/
* f30ab add feature #32 - ability to add new formats to the
* 34ac2 fixed bug #1328 - stack overflow under certain conditions
* 98ca9 initial commit of my project
```

由于 Git 的分支实质上仅是包含所指对象校验和（长度为 40 的 SHA-1 值字符串）的文件，所以它的创建和销毁都异常高效。 创建一个新分支就相当于往一个文件中写入 41 个字节（40 个字符和 1 个换行符）

#### 创建新分支的同时切换过去

通常我们会在创建一个新分支后立即切换过去，这可以用 `git checkout -b <newbranchname>` 一条命令搞定。

### 分支创建和合并

![image-20211012150214485](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012150214485.png)

iss53 表示当前工作的目录，master表示主分支， hotfix 表示主分支的补丁

```shell
git checkout -b hotfix

git commit -a -m 'fix master bug'
```

建立一个 `hotfix` 分支，在该分支上工作直到问题解决，随便将hotfix 合并至 master分支

```shell
git checkout master

git marge hotfix

Updating f42c576..3a0874c
Fast-forward
 index.html | 2 ++
 1 file changed, 2 insertions(+)
```

首先切换至master分支，然后将hotfix 合并至master 分支

> 由于你想要合并的分支 `hotfix` 所指向的提交 `C4` 是你所在的提交 `C2` 的直接后继， 因此 Git 会直接将指针向前移动。换句话说，当试图合并两个分支时， 如果顺着一个分支走下去能够到达另一个分支，那么 Git 在合并两者的时候， 只会简单的将指针向前推进（指针右移），因为这种情况下的合并操作没有需要解决的分歧——这就叫做 “快进（fast-forward）”

现在，最新的修改已经在 `master` 分支所指向的提交快照中

![image-20211012150651493](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012150651493.png)

此时应先删除 hotfix分支，因为master已经移动至别处，hotfix也已经没有用处

```shell
$ git branch -d hotfix
Deleted branch hotfix (3a0874c).
```

![image-20211012151013884](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012151013884.png)

#### 分支合并

运行 `git merge` 命令：

```bash
$ git checkout master
Switched to branch 'master'
$ git merge iss53
Merge made by the 'recursive' strategy.
index.html |    1 +
1 file changed, 1 insertion(+)
```

> 这和你之前合并 `hotfix` 分支的时候看起来有一点不一样。 在这种情况下，开发历史从一个更早的地方开始分叉开来（diverged）。 因为，`master` 分支所在提交并不是 `iss53` 分支所在提交的直接祖先，Git 不得不做一些额外的工作。 出现这种情况的时候，Git 会使用两个分支的末端所指的快照（`C4` 和 `C5`）以及这两个分支的公共祖先（`C2`），做一个简单的三方合并。

![image-20211012151221435](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012151221435.png)

Git 将此次三方合并的结果做了一个新的快照并且自动创建一个新的提交指向它。 这个被称作一次合并提交，它的特别之处在于他有不止一个父提交。

![image-20211012151253703](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012151253703.png)

随后删除 iss53这个分支即可

```shell
git checkout -d iss53
```

#### 遇到冲突时的分支合并

若两个不同分支，修改的是同一文件，在合并时就会产生冲突

```bash
$ git merge iss53
Auto-merging index.html
CONFLICT (content): Merge conflict in index.html
Automatic merge failed; fix conflicts and then commit the result.
```

此时 Git 做了合并，但是没有自动地创建一个新的合并提交。 此时使用`git status ` 命令来查看那些因包含合并冲突而处于未合并（unmerged）状态的文件

```bash
$ git status
On branch master
You have unmerged paths.
  (fix conflicts and run "git commit")

Unmerged paths:
  (use "git add <file>..." to mark resolution)

    both modified:      index.html

no changes added to commit (use "git add" and/or "git commit -a")
```

任何因包含合并冲突而有待解决的文件，都会以未合并状态标识出来。 Git 会在有冲突的文件中加入标准的冲突解决标记，这样可以打开这些包含冲突的文件然后手动解决冲突。 出现冲突的文件会包含一些特殊区段：

```bash
<<<<<<< HEAD:index.html
<div id="footer">contact : email.support@github.com</div>
=======
<div id="footer">
 please contact us at support@github.com
</div>
>>>>>>> iss53:index.html
```

这表示 `HEAD` 所指示的版本（也就是你的 `master` 分支所在的位置，因为你在运行 merge 命令的时候已经检出到了这个分支）在这个区段的上半部分（`=======` 的上半部分），而 `iss53` 分支所指示的版本在 `=======` 的下半部分。 为了解决冲突，你必须选择使用由 `=======` 分割的两部分中的一个，或者你也可以自行合并这些内容。 例如，你可以通过把这段内容换成下面的样子来解决冲突：

```bash
<div id="footer">
please contact us at email.support@github.com
</div>
```

上述的冲突解决方案仅保留了其中一个分支的修改，并且 `<<<<<<<` , `=======` , 和 `>>>>>>>` 这些行被完全删除了。 在你解决了所有文件里的冲突之后，对每个文件使用 `git add` 命令来将其标记为冲突已解决。 一旦暂存这些原本有冲突的文件，Git 就会将它们标记为冲突已解决



使用图形化的工具解决冲突   `git mergetool` 

```bash
$ git mergetool

This message is displayed because 'merge.tool' is not configured.
See 'git mergetool --tool-help' or 'git help config' for more details.
'git mergetool' will now attempt to use one of the following tools:
opendiff kdiff3 tkdiff xxdiff meld tortoisemerge gvimdiff diffuse diffmerge ecmerge p4merge araxis bc3 codecompare vimdiff emerge
Merging:
index.html

Normal merge conflict for 'index.html':
  {local}: modified file
  {remote}: modified file
Hit return to start merge resolution tool (opendiff):
```

然后运行`git status ` 确认所有合并的冲突是否解决

```bash
$ git status
On branch master
All conflicts fixed but you are still merging.
  (use "git commit" to conclude merge)

Changes to be committed:

    modified:   index.html
```

然后运行 `git commit ` 完成合并提交。

### 分支管理

`git branch` 命令不只是可以创建与删除分支。 如果不加任何参数运行它，会得到当前所有分支的一个列表：

```bash
$ git branch
  iss53
* master
  testing
```

注意 `master` 分支前的 `*` 字符：它代表现在检出的那一个分支（也就是说，当前 `HEAD` 指针所指向的分支）。 这意味着如果在这时候提交，`master` 分支将会随着新的工作向前移动。 如果需要查看每一个分支的最后一次提交，可以运行 `git branch -v` 命令：

```bash
git branch -v
 iss53   93b412c fix javascript issue
* master  7a98805 Merge branch 'iss53'
  testing 782fd34 add scott to the author list in the readmes
```

`--merged` 与 `--no-merged` 这两个有用的选项可以过滤这个列表中已经合并或尚未合并到当前分支的分支。 如果要查看哪些分支已经合并到当前分支，可以运行 `git branch --merged`：

```bash
git branch --merged
  iss53
* master
```

之前已经合并了 `iss53` 分支，所以现在看到它在列表中。 在这个列表中分支名字前没有 `*` 号的分支通常可以使用 `git branch -d` 删除掉；你已经将它们的工作整合到了另一个分支，所以并不会失去任何东西。

查看所有包含未合并工作的分支，可以运行 `git branch --no-merged`

```bash
$ git branch --no-merged
```

这里显示了其他分支。 因为它包含了还未合并的工作，尝试使用 `git branch -d` 命令删除它时会失败：

如果真的想要删除分支并丢掉那些工作，如同帮助信息里所指出的，可以使用 `-D` 选项强制删除它。

> 上面描述的选项 `--merged` 和 `--no-merged` 会在没有给定提交或分支名作为参数时， 分别列出已合并或未合并到 **当前** 分支的分支。

### 分支开发流

![image-20211012154554623](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012154554623.png)



### 远程分支

远程引用是对远程仓库的引用（指针），包括分支、标签等等。 可以通过 `git ls-remote <remote>` 来显式地获得远程引用的完整列表， 或者通过 `git remote show <remote>` 获得远程分支的更多信息。 然而，一个更常见的做法是利用远程跟踪分支。

```bash
git remote show origin
* remote origin
  Fetch URL: https://github.com/Jinsipang/trace-specs-actors.git
  Push  URL: https://github.com/Jinsipang/trace-specs-actors.git
  HEAD branch: main
  Remote branches:
    main      tracked
    name      tracked
```

```
远程仓库名字 “origin” 与分支名字 “master” 一样，在 Git 中并没有任何特别的含义一样。 同时 “master” 是当你运行 git init 时默认的起始分支名字，原因仅仅是它的广泛使用， “origin” 是当你运行 git clone 时默认的远程仓库名字。 如果你运行 git clone -o booyah，那么你默认的远程分支名字将会是 booyah/master。
```

如果要与**给定的远程仓库同步数据**，运行 `git fetch <remote>` 命令。从中抓取本地没有的数据，并且更新本地数据库，移动 `origin/master` 指针到更新之后的位置。

![image-20211012155102565](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012155102565.png)

运行 `git remote add` 命令添加一个新的远程仓库引用到当前的项目

### 推送

运行 `git push <remote> <branch>`

要特别注意的一点是当抓取到新的远程跟踪分支时，本地不会自动生成一份可编辑的副本（拷贝）。 换一句话说，这种情况下，不会有一个新的 `serverfix` 分支——只有一个不可以修改的 `origin/serverfix` 指针。可以运行 `git merge origin/serverfix` 将这些工作合并到当前所在的分支。 

### 跟踪分支

从一个远程跟踪分支检出一个本地分支会自动创建所谓的“跟踪分支”（它跟踪的分支叫做“上游分支”）。 跟踪分支是与远程分支有直接关系的本地分支。 如果在一个跟踪分支上输入 `git pull`，Git 能自动地识别去哪个服务器上抓取、合并到哪个分支。

当克隆一个仓库时，它通常会自动地创建一个跟踪 `origin/master` 的 `master` 分支。设置其他的跟踪分支，或是一个在其他远程仓库上的跟踪分支，又或者不跟踪 `master` 分支。运行 `git checkout -b <branch> <remote>/<branch>`。 这是一个十分常用的操作所以 Git 提供了 `--track` 快捷方式

尝试检出的分支 (a) 不存在且 (b) 刚好只有一个名字与之匹配的远程分支，那么 Git 就会为你创建一个跟踪分支。

设置已有的本地分支跟踪一个刚刚拉取下来的远程分支，或者想要修改正在跟踪的上游分支， 你可以在任意时间使用 `-u` 或 `--set-upstream-to` 选项运行 `git branch` 来显式地设置。

```bash
git branch -u origin/name

 git branch --set-upstream-to=origin/name 
```

> 当设置好跟踪分支后，可以通过简写 `@{upstream}` 或 `@{u}` 来引用它的上游分支。 所以在 `master` 分支时并且它正在跟踪 `origin/master` 时，如果愿意的话可以使用 `git merge @{u}` 来取代 `git merge origin/master`。

如果想要查看设置的所有跟踪分支，可以使用 `git branch` 的 `-vv` 选项。 这会将所有的本地分支列出来并且包含更多的信息，如每一个分支正在跟踪哪个远程分支与本地分支是否是领先、落后或是都有。

```bash
$ git branch -vv
  iss53     7e424c3 [origin/iss53: ahead 2] forgot the brackets
  master    1ae2a45 [origin/master] deploying index fix
* serverfix f8674d9 [teamone/server-fix-good: ahead 3, behind 1] this should do it
  testing   5ea463a trying something new
```

这里可以看到 `iss53` 分支正在跟踪 `origin/iss53` 并且 “ahead” 是 2，意味着本地有两个提交还没有推送到服务器上。 也能看到 `master` 分支正在跟踪 `origin/master` 分支并且是最新的。 接下来可以看到 `serverfix` 分支正在跟踪 `teamone` 服务器上的 `server-fix-good` 分支并且领先 3 落后 1， 意味着服务器上有一次提交还没有合并入同时本地有三次提交还没有推送。 最后看到 `testing` 分支并没有跟踪任何远程分支。

需要重点注意的一点是这些数字的值来自于你从每个服务器上最后一次抓取的数据。 这个命令并没有连接服务器，它只会告诉你关于本地缓存的服务器数据。 如果想要统计最新的领先与落后数字，需要在运行此命令前抓取所有的远程仓库。

```bash
git fetch --all ;git branch -vv
```

### 拉取

当 `git fetch` 命令从服务器上抓取本地没有的数据时，它并不会修改工作目录中的内容。 它只会获取数据然后让你自己合并。 然而，有一个命令叫作 `git pull` 在大多数情况下它的含义是一个 `git fetch` 紧接着一个 `git merge` 命令。`git pull` 都会查找当前分支所跟踪的服务器与分支， 从服务器上抓取数据然后尝试合并入那个远程分支。

### 删除远程分支

可以运行带有 `--delete` 选项的 `git push` 命令来删除一个远程分支。

```bash
$ git push origin --delete serverfix
```

基本上这个命令做的只是从服务器上移除这个指针。 Git 服务器通常会保留数据一段时间直到垃圾回收运行，所以如果不小心删除掉了，通常是很容易恢复的

## 变基

在 Git 中整合来自不同分支的修改主要有两种方法：`merge` 以及 `rebase`。

你可以提取在 一个新项目 中引入的补丁和修改，然后在 另一个版本的基础上应用一次。 在 Git 中，这种操作就叫做 **变基（rebase）**

**它的原理是首先找到这两个分支的最近共同祖先 ，然后对比当前分支相对于该祖先的历次提交，提取相应的修改并存为临时文件， 然后将当前分支指向目标基底  最后以此将之前另存为临时文件的修改依序应用。** 

![image-20211012162948862](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012162948862.png)

现在回到 `master` 分支，进行一次快进合并。

```bash
git checkout master

git merge name
```

![image-20211012163212863](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012163212863.png)





![image-20211012163910521](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012163910521.png)

将C9 合并至master中，但是不合并C10

使用 `git rebase` 命令的 `--onto` 选项，选中在 `client` 分支里但不在 `server` 分支里的修改（即 `C8` 和 `C9`），将它们在 `master` 分支上重放：

```bash
git rebase --onto master server client
```

> 取出 `client` 分支，找出它从 `server` 分支分歧之后的补丁， 然后把这些补丁在 `master` 分支上重放一遍，让 `client` 看起来像直接基于 `master` 修改一样。

![image-20211012164050270](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012164050270.png)

现在可以快进合并 `master` 分支了， 包含来自client分支的修改

```bash
git checkout master

git merge client
```

![image-20211012164137148](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012164137148.png)

使用 `git rebase <basebranch> <topicbranch>` 命令可以直接将主题分支 （即本例中的 `server`）变基到目标分支（即 `master`）上。这样做能省去你先切换到 `server` 分支，再对其执行变基命令的多个步骤。

```bash
git reabase master server
```

![image-20211012164235725](C:\Users\35730\AppData\Roaming\Typora\typora-user-images\image-20211012164235725.png)``

之后合并即可

```bash
git checkout master

git merge server
```

```bash
$ git branch -d client
$ git branch -d server
```

之后删除分支

变基的原则：

**如果提交存在于你的仓库之外，而别人可能基于这些提交进行开发，那么不要执行变基。**

变基操作的实质是丢弃一些现有的提交，然后相应地新建一些内容一样但实际上不同的提交。

> 如果你已经将提交推送至某个仓库，而其他人也已经从该仓库拉取提交并进行了后续工作，此时，如果你用 `git rebase` 命令重新整理了提交并再次推送，你的同伴因此将不得不再次将他们手头的工作与你的提交进行整合，如果接下来你还要拉取并整合他们修改过的提交，事情就会变得一团糟。

















