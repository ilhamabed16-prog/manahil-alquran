import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final p = await SharedPreferences.getInstance();
  runApp(ManahilApp(prefs: p));
}

class ManahilApp extends StatefulWidget {
  final SharedPreferences prefs;
  const ManahilApp({super.key, required this.prefs});
  @override State<ManahilApp> createState() => _ManahilAppState();
}

class _ManahilAppState extends State<ManahilApp> {
  late bool dark;
  late double scale;
  @override void initState() {
    super.initState();
    dark = widget.prefs.getBool('dark') ?? false;
    scale = widget.prefs.getDouble('scale') ?? 1.0;
  }
  @override Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مناهـل القرآن',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xff8e7a68)),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Home(prefs: widget.prefs, dark: dark, scale: scale,
        onDark: (v){setState(()=>dark=v); widget.prefs.setBool('dark',v);},
        onScale: (v){setState(()=>scale=v); widget.prefs.setDouble('scale',v);}),
    );
  }
}

class Home extends StatelessWidget {
  final SharedPreferences prefs; final bool dark; final double scale;
  final ValueChanged<bool> onDark; final ValueChanged<double> onScale;
  const Home({super.key,required this.prefs,required this.dark,required this.scale,
    required this.onDark,required this.onScale});

  @override Widget build(BuildContext context) {
    final items = [
      ['القرآن الكريم', Icons.menu_book, QuranPage()],
      ['اختبار التحفيظ', Icons.psychology_alt, MemorizationPage()],
      ['أحكام التجويد', Icons.record_voice_over, SimplePage('أحكام التجويد',[
        'مخارج الحروف','النون الساكنة والتنوين','الميم الساكنة','المدود',
        'القلقلة','التفخيم والترقيق','الوقف والابتداء','اختبارات وتمارين'])],
      ['الأذكار', Icons.wb_sunny_outlined, SimplePage('الأذكار',[
        'أذكار الصباح','أذكار المساء','أذكار النوم','أذكار الصلاة',
        'أذكار دخول البيت','أذكار الخروج','أذكار متنوعة'])],
      ['السبحة الإلكترونية', Icons.touch_app, TasbeehPage()],
      ['الصلاة والقبلة', Icons.mosque_outlined, SimplePage('الصلاة والقبلة',[
        'مواقيت الصلاة','الأذان والمؤذنون','الإقامة','تنبيه الفجر','القبلة',
        'التقويم الهجري','صلاة الضحى','قيام الليل','صيام النوافل','الصدقة'])],
      ['القصص والسيرة', Icons.auto_stories, SimplePage('القصص والسيرة',[
        'قصص الأنبياء','السيرة النبوية','زوجات النبي ﷺ','قصص الصحابة'])],
      ['المكتبة الإسلامية', Icons.local_library, SimplePage('المكتبة الإسلامية',[
        'كتب دينية','كتب التفسير','كتب السيرة','كتب الأحاديث',
        'الجزرية','تحفة الأطفال','الأربعون النووية','الأصول الثلاثة','كتاب التوحيد'])],
      ['التحديات وبرنامج رمضان', Icons.emoji_events, SimplePage('التحديات وبرنامج رمضان',[
        'حفظ القرآن','صيام النوافل','قيام الليل','الصدقات','حفظ المتون',
        'ختمة أسبوعية','ختمة نصف شهرية','ختمة شهرية','عشر الأواخر'])],
      ['لعبة الأسئلة الإسلامية', Icons.quiz, QuizPage()],
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('مناهـل القرآن'), centerTitle: true,
        actions:[IconButton(icon:const Icon(Icons.settings),onPressed:()=>Navigator.push(context,
          MaterialPageRoute(builder:(_)=>SettingsPage(dark:dark,scale:scale,onDark:onDark,onScale:onScale))))]),
      body: ListView(padding:const EdgeInsets.all(16),children:[
        Container(padding:const EdgeInsets.all(22),
          decoration:BoxDecoration(borderRadius:BorderRadius.circular(28),
          color:Theme.of(context).colorScheme.primaryContainer),
          child:const Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
            Text('مناهـل القرآن',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),
            SizedBox(height:6),Text('دربك لن يضيق',style:TextStyle(fontSize:18)),
            SizedBox(height:10),Text('وردك • حفظك • أذكارك • صلاتك • تعلمك') ])),
        const SizedBox(height:16),
        GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),
          itemCount:items.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.15),
          itemBuilder:(c,i)=>Card(child:InkWell(borderRadius:BorderRadius.circular(16),
            onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>items[i][2] as Widget)),
            child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
              Icon(items[i][1] as IconData,size:34),const SizedBox(height:9),
              Text(items[i][0] as String,textAlign:TextAlign.center,
                style:const TextStyle(fontWeight:FontWeight.w600))]))))
      ]),
    );
  }
}

class QuranPage extends StatefulWidget { const QuranPage({super.key}); @override State<QuranPage> createState()=>_QuranPageState(); }
class _QuranPageState extends State<QuranPage> {
  String reading='حفص'; int repeat=1;
  final verses=const [
    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    'الرَّحْمَٰنِ الرَّحِيمِ','مَالِكِ يَوْمِ الدِّينِ',
    'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
    'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
    'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ'];
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('القرآن الكريم'),centerTitle:true),
    body:ListView(padding:const EdgeInsets.all(14),children:[
      Row(children:[
        Expanded(child:DropdownButtonFormField<String>(value:reading,decoration:const InputDecoration(labelText:'الرواية'),
          items:const[DropdownMenuItem(value:'حفص',child:Text('حفص عن عاصم')),
            DropdownMenuItem(value:'ورش',child:Text('ورش عن نافع'))],
          onChanged:(v)=>setState(()=>reading=v!))),
        const SizedBox(width:10),
        Expanded(child:DropdownButtonFormField<int>(value:repeat,decoration:const InputDecoration(labelText:'التكرار'),
          items:[1,2,3,5,10].map((n)=>DropdownMenuItem(value:n,child:Text('$n مرات'))).toList(),
          onChanged:(v)=>setState(()=>repeat=v!))),
      ]),
      const SizedBox(height:10),
      const Text('الفاتحة • نموذج واجهة',textAlign:TextAlign.right,style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      ...verses.asMap().entries.map((e)=>Card(child:ListTile(
        leading:CircleAvatar(child:Text('${e.key+1}')),
        title:Text(e.value,textAlign:TextAlign.right,style:const TextStyle(fontSize:24,height:1.8)),
        trailing:IconButton(icon:const Icon(Icons.repeat),onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content:Text('تكرار الآية ${e.key+1} عدد $repeat مرات')))),
        onTap:()=>showModalBottomSheet(context:context,builder:(_)=>const SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[
          ListTile(leading:Icon(Icons.book),title:Text('التفسير')),
          ListTile(leading:Icon(Icons.translate),title:Text('معاني الكلمات والترجمة')),
          ListTile(leading:Icon(Icons.history_edu),title:Text('سبب النزول')),
          ListTile(leading:Icon(Icons.bookmark_border),title:Text('علامة مرجعية'))]))),
      ))),
    ]));
}

class MemorizationPage extends StatefulWidget { const MemorizationPage({super.key}); @override State<MemorizationPage> createState()=>_MemState(); }
class _MemState extends State<MemorizationPage> {
  bool show=true; int score=0; final c=TextEditingController();
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('اختبار التحفيظ')),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      SwitchListTile(title:const Text('إظهار الآية'),value:show,onChanged:(v)=>setState(()=>show=v)),
      if(show) const Text('وَإِيَّاكَ نَسْتَعِينُ',textAlign:TextAlign.right,style:TextStyle(fontSize:28)),
      const SizedBox(height:12),TextField(controller:c,maxLines:4,textAlign:TextAlign.right,
        decoration:const InputDecoration(labelText:'اكتب ما حفظته',border:OutlineInputBorder())),
      const SizedBox(height:10),FilledButton(onPressed:()=>setState(()=>score++),child:const Text('فحص الإجابة')),
      Text('النقاط: $score',textAlign:TextAlign.center),
      const SizedBox(height:18),
      const Text('الإصدار الإنتاجي يمكن أن يضيف التسجيل الصوتي، تحديد مواضع الخطأ، المتشابهات، وخطة المراجعة.',textAlign:TextAlign.right),
    ]));
}

class TasbeehPage extends StatefulWidget { const TasbeehPage({super.key}); @override State<TasbeehPage> createState()=>_TasState(); }
class _TasState extends State<TasbeehPage> {
  int n=0; String dhikr='أستغفر الله';
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('السبحة الإلكترونية')),
    body:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      DropdownButton<String>(value:dhikr,items:const['أستغفر الله','سبحان الله','الحمد لله','الله أكبر']
        .map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),onChanged:(v)=>setState(()=>dhikr=v!)),
      Text('$n',style:const TextStyle(fontSize:72,fontWeight:FontWeight.bold)),Text(dhikr,style:const TextStyle(fontSize:24)),
      const SizedBox(height:20),GestureDetector(onTap:()=>setState(()=>n++),child:Container(width:210,height:210,
        decoration:BoxDecoration(shape:BoxShape.circle,color:Theme.of(context).colorScheme.primaryContainer),
        child:const Center(child:Text('اضغط للتسبيح')))),
      TextButton(onPressed:()=>setState(()=>n=0),child:const Text('تصفير'))
    ]));
}

class QuizPage extends StatefulWidget { const QuizPage({super.key}); @override State<QuizPage> createState()=>_QuizState(); }
class _QuizState extends State<QuizPage> { int selected=-1,score=0;
  final o=['114 سورة','100 سورة','30 سورة','60 سورة'];
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('لعبة الأسئلة الإسلامية')),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('كم عدد سور القرآن الكريم؟',textAlign:TextAlign.right,style:TextStyle(fontSize:23)))),
      ...List.generate(o.length,(i)=>RadioListTile<int>(value:i,groupValue:selected,onChanged:(v)=>setState(()=>selected=v!),title:Text(o[i]))),
      FilledButton(onPressed:(){if(selected==0)setState(()=>score++);},child:const Text('تحقق')),
      Text('النقاط: $score',textAlign:TextAlign.center)
    ]));
}

class SimplePage extends StatelessWidget { final String title; final List<String> items; const SimplePage(this.title,this.items,{super.key});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(title),centerTitle:true),
    body:ListView(padding:const EdgeInsets.all(16),children:items.map((x)=>Card(child:ListTile(
      leading:const Icon(Icons.menu_book_outlined),title:Text(x,textAlign:TextAlign.right),
      trailing:const Icon(Icons.chevron_left)))).toList())); }

class SettingsPage extends StatelessWidget { final bool dark; final double scale; final ValueChanged<bool> onDark; final ValueChanged<double> onScale;
  const SettingsPage({super.key,required this.dark,required this.scale,required this.onDark,required this.onScale});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('الإعدادات')),
    body:ListView(children:[
      SwitchListTile(title:const Text('الوضع الليلي'),value:dark,onChanged:onDark),
      const ListTile(title:Text('حجم الخط')),Slider(min:.85,max:1.35,divisions:10,value:scale,onChanged:onScale),
      const ListTile(title:Text('نوع الخط'),subtitle:Text('يمكن إضافة خطوط عربية/قرآنية موثوقة إلى assets/fonts')),
      const ListTile(title:Text('اللغة'),subtitle:Text('العربية واللغات الأخرى')),
      const ListTile(title:Text('التذكيرات'),subtitle:Text('صوت أو رنة أو إشعار منبثق'))
    ])); }
