# Java 17

Java 17 是 LTS（长期支持）版本，是 Spring Boot 3 的最低要求版本。

## 快速参考

### Java 17 主要新特性

**1. Sealed Classes（密封类）- JEP 409**
```java
// 限制哪些类可以继承或实现
public sealed interface Shape
    permits Circle, Rectangle, Triangle {
    double area();
}

public final class Circle implements Shape {
    private final double radius;
    public Circle(double radius) { this.radius = radius; }
    @Override
    public double area() { return Math.PI * radius * radius; }
}
```

**2. Pattern Matching for instanceof - JEP 394**
```java
// 旧写法
if (obj instanceof String) {
    String s = (String) obj;
    System.out.println(s.length());
}

// 新写法
if (obj instanceof String s) {
    System.out.println(s.length());
}
```

**3. Switch 表达式与模式匹配 - JEP 361, 406**
```java
// Switch 表达式（Java 14 正式引入）
String day = switch (dayOfWeek) {
    case MONDAY, FRIDAY, SUNDAY -> "6";
    case TUESDAY                -> "7";
    default                     -> "8";
};

// Java 17 预览：类型模式
static String format(Object o) {
    return switch (o) {
        case Integer i -> String.format("int %d", i);
        case Long l    -> String.format("long %d", l);
        case Double d  -> String.format("double %f", d);
        case String s  -> String.format("String %s", s);
        default        -> o.toString();
    };
}
```

**4. Records（记录类）- JEP 395**
```java
// 不可变数据类，自动生成构造器、getter、equals、hashCode、toString
public record User(Long id, String username, String email) {}

// 使用
User user = new User(1L, "admin", "T1T2c@cjdwnU.6aa");
System.out.println(user.username()); // admin
```

**5. Text Blocks（文本块）- JEP 378**
```java
// 使用 """ 定义多行字符串
String json = """
    {
        "name": "AIguard",
        "version": "1.0.0",
        "description": "Smart Home Security System"
    }
    """;
```

**6. NullPointerException 增强 - JEP 358**
```java
// 更好的NPE诊断信息，精确到哪个变量为null
// 示例错误信息：
// Cannot invoke "String.length()" because "user.name" is null
```

**7. ZGC / Shenandoah GC 改进**
- ZGC 低延迟垃圾回收器正式可用
- 暂停时间不超过 1ms，支持 TB 级堆内存

### 核心概念速查

**Stream API**
```java
List<User> users = userRepository.findAll();

// 过滤、转换、聚合
List<String> adminNames = users.stream()
    .filter(u -> u.role().equals(Role.ADMIN))
    .map(User::username)
    .sorted()
    .toList(); // Java 16+ 直接 toList()

// 分组
Map<Role, List<User>> byRole = users.stream()
    .collect(Collectors.groupingBy(User::role));
```

**Optional**
```java
Optional<User> userOpt = userRepository.findById(id);
String name = userOpt
    .map(User::username)
    .orElse("未知用户");

// 链式调用
userOpt.ifPresent(u -> {
    System.out.println("找到用户: " + u.username());
});
```

**模块系统（JPMS）- 了解即可**
- Java 9 引入，大型项目可使用
- 大多数 Spring Boot 项目使用 classpath 而非 module path

### JDK 安装（树莓派 aarch64）

```bash
# 方法1：apt 安装（OpenJDK）
sudo apt update
sudo apt install -y openjdk-17-jdk openjdk-17-jre

# 方法2：手动安装（Azul Zulu 或 BellSoft Liberica 支持 ARM64）
# 下载：https://bell-sw.com/pages/downloads/#/java-17-lts
# 解压并配置环境变量
# export JAVA_HOME=/path/to/jdk-17
# export PATH=$JAVA_HOME/bin:$PATH
```

## 常见坑点

1. **版本兼容性**
   - Spring Boot 3 必须使用 JDK 17+，不支持 JDK 8/11
   - 部分旧库可能不兼容 JDK 17，需要升级版本或添加 JVM 参数：
     ```
     --add-opens java.base/java.lang=ALL-UNNAMED
     ```

2. **Record 与 Bean 规范冲突**
   - Record 是不可变的，没有 setter 方法
   - JPA/Hibernate 实体通常需要无参构造器和 setter，不建议使用 Record 作为实体
   - Record 适合用作 DTO、配置属性、事件对象

3. **sealed class 的 permits 限制**
   - sealed 类的 permits 子类必须与父类在同一模块，或同一包（未命名模块时）
   - final 子类不能被继承；non-sealed 子类可以开放继承

4. **Switch 模式匹配在 Java 17 中是预览特性**
   - Java 17 需要 `--enable-preview` 才能使用类型模式 switch
   - Java 21 中该特性正式转正

5. **日期时间 API 使用误区**
   ```java
   // 错误：使用旧的 Date/Calendar（线程不安全、API 混乱）
   Date d = new Date();

   // 正确：使用 java.time（Java 8+ 线程安全、API 清晰）
   LocalDate today = LocalDate.now();
   LocalDateTime now = LocalDateTime.now();
   Instant timestamp = Instant.now(); // UTC时间戳
   ```

6. **并行流陷阱**
   - `parallelStream()` 使用 ForkJoinPool.commonPool()，线程数等于 CPU 核心数
   - 阻塞操作（如 DB 查询）不要用并行流，会导致线程池饥饿

## 官方链接

详见 [official-links.md](official-links.md)。

- Java 17 官方文档：https://docs.oracle.com/en/java/javase/17/
- OpenJDK 17 项目：https://openjdk.org/projects/jdk/17/
- JDK 17 新特性（OpenJDK）：https://openjdk.java.net/projects/jdk/17/
