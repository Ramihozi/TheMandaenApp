import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart'; // Import GetX

import 'profile_tab/community_profile_controller.dart';
import 'infoDetailedScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  Map<String, String>? dailyVerse;
  final ProfileController profileController = Get.find(); // Access ProfileController

  // Donation URL
  final String donationUrl = "https://ramihozi.github.io/GinzAppPage/donations.html"; // Replace with your actual donation link


  List<Map<String, dynamic>> informationalItems = [
    {
      'title': 'History',
      'title_ar': 'التاريخ',
      'paragraphs': [
        'Mandaeanism is the oldest surviving religion that can be traced back to the pre-Christian era. A large number of the Mandaeans lived in the Jordan valley, Syria and its surrounding areas. Other communities of the Mandaeans had also long settled throughout the Mesopotamian and Persian lands. '
            'They are considered as the indigenous Mesopotamian people. After the death of their last great Teacher, John the Baptist, '
            'the communities in Jordan and Palestine came under persecution and eventually migrated to join other Mandaeans. '
            'They settled in Iraq and Iran, especially around the upper middle and lower Euphrates, the Tigris and the Kāron Rivers in Khuzestan Province. Today, the Mandaeans number more than 80,000 strong believers, but no longer concentrate in Iraq and Iran.',

        'The twentieth century has brought about a dramatic change in the geographical location of Mandaean communities. The majority of Mandaeans now live in diaspora due to the severe persecution and regional wars in Iraq and Iran. The most recent disruption to Mandaean life in the Middle East was due to the United States’ invasion of Iraq.'
            ' The Mandaeans can be found in large numbers now living in Europe, Australia, the United States, Canada, New Zealand, as well as Syria, Jordan, Turkey and Indonesia.'

        '\n\nThere are probably less than 5,000 Mandaeans living in Iraq and roughly less than 1,700 remaining in Iran. The Mandaeans have been traditionally involved in various artisan trades. They are well-educated and highly skilled professionals, usually working as gold and silversmiths or as jewelers.'
      ],
      'paragraphs_ar': [
        'المندائية هي أقدم ديانة باقية يمكن إرجاعها إلى العصر ما قبل المسيحي. عاش عدد كبير من المندائيين في وادي الأردن وسوريا والمناطق المحيطة بها. كما استوطنت مجتمعات أخرى من المندائيين منذ فترة طويلة في جميع أنحاء بلاد ما بين النهرين والأراضي الفارسية.',
        'يعتبرون الشعب الأصلي لبلاد ما بين النهرين. بعد وفاة آخر معلمهم العظيم، يوحنا المعمدان،',
        'تعرضت المجتمعات في الأردن وفلسطين للاضطهاد وهاجرت في النهاية للانضمام إلى المندائيين الآخرين.',
        'استقروا في العراق وإيران، وخاصة حول الفرات الأوسط العلوي والسفلي، ونهر دجلة ونهر الكارون في محافظة خوزستان. يبلغ عدد المندائيين اليوم أكثر من 80.000 مؤمن قوي، لكنهم لم يعودوا يتركزون في العراق وإيران.',
        'لقد أحدث القرن العشرون تغييرًا جذريًا في الموقع الجغرافي للمجتمعات المندائية. يعيش أغلب المندائيين الآن في الشتات بسبب الاضطهاد الشديد والحروب الإقليمية في العراق وإيران. وكان آخر اضطراب في حياة المندائيين في الشرق الأوسط بسبب غزو الولايات المتحدة للعراق.',
        'يمكن العثور على المندائيين بأعداد كبيرة يعيشون الآن في أوروبا وأستراليا والولايات المتحدة وكندا ونيوزيلندا وكذلك سوريا والأردن وتركيا وإندونيسيا.',
        '\n\nربما يوجد أقل من 5000 من المندائيين يعيشون في العراق وما يقرب من أقل من 1700 متبقٍ في إيران. كان المندائيون يشاركون تقليديًا في مختلف المهن الحرفية. إنهم محترفون متعلمون جيدًا وذوو مهارات عالية، وعادة ما يعملون كصائغين للذهب والفضة أو كصائغين.'
      ],
      'image': 'assets/images/darfesh1.jpeg',
    },
    {
      'title': 'Beliefs',
      'title_ar': 'المعتقدات',
      'paragraphs': [
        'Life: Recognition of the existence of one God, whom Nasurai call "Hayyi" which in Aramaic means "the Living" or life itself. The Great Life (or Supreme Deity) is a personification of the creative and sustaining force of the universe, and is spoken of always in the impersonal plural, it remains mystery and abstraction. '
            'The symbol of the Great Life is flowing living water or yardna. Because of this, flowing water holds a central place in all Nasurai rituals, hence the necessity of living near rivers.',
        'Light: The second vivifying power is light, which is represented by a personification of light, Melka d Nhura (the King of Light) and the light spirits, who bestow health, strength, virtue and justice. In the ethical system of the Mandaeans, cleanliness, health of body and ritual obedience must be accompanied by purity of mind, health of conscience and obedience to moral laws. '
            'A phrase in the Manual of Discipline reads: that they may behold the Light of Life.',
        'Immortality: The third important rite of the religion is the belief in the immortality of the soul, and its close relationship with the souls of its ancestors, immediate and divine. The fate of the soul is a chief concern, while the body is treated with disdain. '
            'Belief in the existence of the next life, in which there will be reward and punishment. The sinner will be punished in al-Matarathi and then enter Paradise. There is no eternal punishment because God is merciful and forgiving.',
      ],
      'paragraphs_ar': [
        'الحياة: الاعتراف بوجود إله واحد، يسميه النصوريون "هايي" والتي تعني في الآرامية "الحي" أو الحياة ذاتها. الحياة العظيمة (أو الإله الأعظم) هي تجسيد للقوة الخلاقة الداعمة للكون، ويتم التحدث عنها دائمًا بصيغة الجمع غير الشخصية، فهي تظل غامضة ومجردة.',
        'رمز الحياة العظيمة هو الماء الحي المتدفق أو الياردنا. ولهذا السبب، يحتل الماء المتدفق مكانة مركزية في جميع طقوس النصوريين، ومن هنا تأتي ضرورة العيش بالقرب من الأنهار.',
        'النور: القوة المنشطة الثانية هي النور، والتي يمثلها تجسيد للنور، ملكا نورا (ملك النور) والأرواح النورانية، التي تمنح الصحة والقوة والفضيلة والعدالة. في النظام الأخلاقي للمندائيين، يجب أن تكون النظافة وصحة الجسم والطاعة الطقسية مصحوبة بنقاء العقل وصحة الضمير والطاعة للقوانين الأخلاقية.',
        'تقول عبارة في كتاب الانضباط: لينظروا نور الحياة.',
        'الخلود: ثالث أهم طقوس الدين هو الاعتقاد بخلود الروح، وعلاقتها الوثيقة بأرواح أسلافها، المباشرة والإلهية. إن مصير الروح هو الشغل الشاغل، بينما يعامل الجسد بازدراء.',
        'الإيمان بوجود الحياة الآخرة، حيث سيكون هناك ثواب وعقاب. سيعاقب الخاطيء في الماثي ثم يدخل الجنة. لا يوجد عقاب أبدي لأن الله رحيم وغفور.',
      ],
      'image': 'assets/images/hayyi.jpeg',
    },
    {
      'title': 'Practices',
      'title_ar': 'الممارسات',
      'paragraphs': [
        'PRAYER: Mandaeans must face the North (Pole) Star during prayers. This mis-conception of star worship comes from the fact that although the Mandaean are monotheists, they pay adoration to the angels and the good and free spirits which they believe reside in the stars and from which they govern the world under the Supreme Deity. Kneeling and prostration during prayer is unknown, neither is the covering of the face with the hands at any time.'
            ' The head is held erect, and the hands are not used. Priests are required to pray a different set prayer each day of the week. Prayer hours are dawn, noon and dusk.',
        'NO CIRCUMCISION: One of their inviolable beliefs was the integrity of the physical body. No part of it should be cut off, for just as God created the person sound and complete so should this trust be returned to him. Circumcision is included in this prohibition.',
        'RESPECT FOR RIVERS: Respect for and sanctification of rivers is such that Mandaeans always try to live near their banks. A major sin as mentioned in the Holy Books is that a person should urinate in a river. However, it is recommended to throw left-over food in water especially the food remaining from ceremonies remembering a deceased person which will be eaten by the river fish.'
            ' This is because the river or Yardna represents Life and Light from which everything was formed and so will return to it. - It involves communion with the Light World and the long departed Souls.',
        'MASBUTA BAPTISM: The third ablution, or full baptism, encompasses all aspects of baptism and must be performed by a priest or priestess. This ablution is known as masbuta (maswetta) includes the sacraments of oil, bread (known as pihtha) and water (from the river only, known as mambuha), the kushta (the hand grasp and kiss) and the final blessing by laying the right hand of the priest on the head of the baptized person.'
            ' The masbuta should take place on Sunday, after major defilement\'s (i.e.. childbirth, marriage, illness and even after a journey) and especially for those who have lied or who have had violent quarrels, indeed after any action which is ashamed of. Major sins such as theft, murder, and adultery require more than one baptism.',
        'DIET & PURITY: Food is also ritually cleansed, such as fruits and vegetables before consumption. Other items like the rasta (robes) and kitchen utensils such as pots and pans undergo frequent ritual purifications. Salt is the only exception. Ganzivri (Bishops) and priests must only eat of the food they prepare themselves and their bread may not be baked with that of lay persons. For Ganzivri (Bishops) wine, coffee and tobacco are forbidden to them and they must avoid eating hot or cooked food. '
            'All their fruits and vegetables must be eaten raw. Water is the only beverage of a priest and this must be taken directly from the river or spring. The Mandaeans also use other terms to differentiate amongst themselves on basis of ritual cleanliness, Suwadi is used for laymen, Hallali is applied to ritually pure men, who of their own will follow a high religious standard, and of course Nasurai used for priests. Only that grows from a seed is lawful for food (hence a mushroom is forbidden).'
            ' In practice little meat is eaten, and the attitude towards slaughter is always apologetic, perhaps because all original Nasurai were vegetarians and meat eating only crept in after a departure from their original faith. All killing and blood letting is supposedly sinful and it is forbidden to kill female beasts. Flies, scorpions and all harmful stinging things may be slain without sin. Under Mandaean customs every mother must suckle her own child, it is forbidden to act as a foster mother for hire. The child\'s education and upbringing is the duty of the father, until the child reaches the age of 15 (or 20 according to others, which was the age of adulthood in the Dead Sea Scrolls and Pythagorean tradition).'
      ],
      'paragraphs_ar': [
        'الصلاة: يجب على المندائيين أن يوجهوا صلواتهم نحو نجم الشمال (القطب الشمالي). وينبع هذا المفهوم الخاطئ لعبادة النجوم من حقيقة مفادها أنه على الرغم من كون المندائيين موحدين، إلا أنهم يعبدون الملائكة والأرواح الطيبة والحرة التي يعتقدون أنها تسكن النجوم والتي يحكمون العالم منها تحت الإله الأعلى. ولا يُعرف الركوع والسجود أثناء الصلاة، ولا يُعرف أيضًا تغطية الوجه باليدين في أي وقت.',
        'يكون الرأس منتصبًا، ولا يتم استخدام اليدين. ويُطلب من الكهنة أن يصلوا صلاة مختلفة كل يوم من أيام الأسبوع. وساعات الصلاة هي الفجر والظهيرة والغسق.',
        'لا للختان: كان من بين معتقداتهم التي لا يمكن المساس بها سلامة الجسد المادي. فلا يجوز قطع أي جزء منه، فكما خلق الله الإنسان سليمًا وكاملاً، فلابد أن تُعاد إليه هذه الأمانة. والختان مشمول بهذا الحظر.',
        'احترام الأنهار: إن احترام الأنهار وتقديسها من الأمور التي يحرص المندائيون على العيش بالقرب منها. ومن الذنوب الكبرى كما وردت في الكتب المقدسة أن يبول الإنسان في النهر. ولكن من المستحب أن يلقى الإنسان بقايا الطعام في الماء وخاصة الطعام المتبقي من مراسم إحياء ذكرى المتوفى والذي سوف تأكله أسماك النهر.',
        'هذا لأن النهر أو ياردنا يمثل الحياة والنور الذي تشكل منه كل شيء وسيعود إليه. - إنه ينطوي على التواصل مع عالم النور والأرواح التي رحلت منذ زمن طويل.',
        'معمودية ماسبوتا: تشمل الوضوء الثالث، أو المعمودية الكاملة، جميع جوانب المعمودية ويجب أن يقوم بها كاهن أو كاهنة. يُعرف هذا الوضوء باسم ماسبوتا (ماسوتا) ويشمل أسرار الزيت والخبز (المعروف باسم بيهتا) والماء (من النهر فقط، والمعروف باسم مامبوها)، والكوشتا (قبضة اليد والقبلة) والبركة النهائية بوضع اليد اليمنى للكاهن على رأس الشخص المعمد',
        'يجب أن تتم المعمودية يوم الأحد، بعد ارتكاب الجرائم الكبرى (مثل الولادة، الزواج، المرض، وحتى بعد السفر) وخاصة بالنسبة لأولئك الذين كذبوا أو الذين خاضوا مشاجرات عنيفة، بل وبعد أي عمل يخجل منه الناس. الخطايا الكبرى مثل السرقة والقتل والزنا تتطلب أكثر من معمودية واحدة.',
        'النظام الغذائي والطهارة: يتم تطهير الطعام أيضًا طقسيًا، مثل الفواكه والخضروات قبل تناولها. تخضع أشياء أخرى مثل الراستا (الأردية) وأدوات المطبخ مثل الأواني والمقالي لتطهير طقسي متكرر. الملح هو الاستثناء الوحيد. يجب على الأساقفة والكهنة أن يأكلوا فقط من الطعام الذي يعدونه بأنفسهم ولا يجوز خبز خبزهم مع خبز الأشخاص العاديين. بالنسبة للأساقفة، يُحظر عليهم النبيذ والقهوة والتبغ ويجب عليهم تجنب تناول الطعام الساخن أو المطبوخ.',
        'يجب أن تؤكل جميع فواكههم وخضرواتهم نيئة. والماء هو المشروب الوحيد للكاهن ويجب أن يأخذه مباشرة من النهر أو النبع. ويستخدم المندائيون أيضًا مصطلحات أخرى للتمييز فيما بينهم على أساس النظافة الطقسية، حيث يستخدم السوادي للعلمانيين، والهلالي يطلق على الرجال الطاهرين طقسيًا، الذين يتبعون معيارًا دينيًا عاليًا من تلقاء أنفسهم، وبالطبع يستخدم النصوري للكهنة. فقط ما ينمو من البذور هو المشروع للأكل (ومن ثم فإن الفطر محرم)',
        'في الممارسة العملية، لا يأكلون سوى القليل من اللحوم، والموقف من الذبح هو دائمًا اعتذاري، ربما لأن جميع النصارى الأصليين كانوا نباتيين ولم يتسلل أكل اللحوم إلا بعد انحرافهم عن عقيدتهم الأصلية. يُفترض أن كل القتل وسفك الدماء خطيئة ويُحظر قتل الحيوانات الإناث. يجوز قتل الذباب والعقارب وكل الأشياء اللاسعة الضارة دون خطيئة. وفقًا للعادات المندائية، يجب على كل أم أن ترضع طفلها، ويُحظر العمل كأم حاضنة مقابل أجر. تعليم الطفل وتربيته هو واجب الأب، حتى يبلغ الطفل سن الخامسة عشرة (أو العشرين وفقًا لآخرين، وهو سن البلوغ في مخطوطات البحر الميت والتقاليد الفيثاغورية).',
        ],
      'image': 'assets/images/masbutta.jpeg',
    },
    {
      'title': 'Festivals',
      'title_ar': 'المهرجانات',
      'paragraphs': [
        'Parwanaya (Dehwa Rabba) \nWhen: Celebrated in late winter, typically in March. \nDuration: 5 days. \nSignificance: This is the most important festival in the Mandaean calendar, marking the creation of the world and the renewal of life. It is a time for major rituals, including baptisms (masbuta), and for making offerings to spirits and deities. \nActivities: The festival involves daily rituals of purification and baptism in flowing water, prayers, and community feasts. It\'s also a time for the renewal of vows and spiritual cleansing.',
        '\nDehwa Hanina (Little Feast) \nWhen: Typically celebrated in early summer. \nSignificance: This festival marks when Malka Hebil-Ziwa returned to the world of light after he won the war against the world of dark. \nActivities: The celebration includes rituals similar to those of Parwanaya, with a focus on renewal and purification. Community gatherings and feasts are also a key part of the festivities.',
        '\nDehwa d-Šitil (Festival of Sitil) \nWhen: Celebrated in late summer or early autumn. \nSignificance: This festival honors the figure of Šitil (Seth), considered a divine being and a savior figure in Mandaean belief. \nActivities: It involves rituals of purification and baptism, prayers, and communal meals. It is also a time for remembering the dead and making offerings in their honor.',
        '\nDehwa d-Edya (New Year Festival) \nWhen: Typically celebrated in early January. \nSignificance: This festival marks the arrival of light into the world. \nActivities: It involves rituals of purification, special prayers, and feasting. It is a time of joy and renewal, with the community coming together to celebrate the new beginning.',
        '\nQina (Sunday of Remembrance) \nWhen: Celebrated on the first Sunday after Parwanaya. \nSignificance: This day is dedicated to the memory of the deceased and the veneration of ancestors. \nActivities: Rituals include prayers, offerings, and baptisms conducted in honor of the departed souls.',
        '\nDehwa Daimana (Feast) \nWhen: Typically Celebrated In The Middle Of May. \nSignificance: A festival celebrating the birthday of John the Baptist, the Mandaean greatest and final prophet. Children are baptized for the first time during this festival.'
      ],
      'paragraphs_ar': [
        'الباروانايا (دهوا رابا) \nمتى: يحتفل به في أواخر الشتاء، عادة في شهر مارس. \nالمدة: 5 أيام. \nالأهمية: هذا هو المهرجان الأكثر أهمية في التقويم المندائي، ويمثل خلق العالم وتجديد الحياة. إنه وقت للطقوس الكبرى، بما في ذلك المعمودية (المصبوبة)، وتقديم القرابين للأرواح والآلهة. \nالأنشطة: يتضمن المهرجان طقوسًا يومية للتطهير والمعمودية في المياه الجارية، والصلاة، والأعياد المجتمعية. إنه أيضًا وقت لتجديد النذور والتطهير الروحي.',
        'دهوا حنينا (العيد الصغير) \nمتى: يحتفل به عادة في أوائل الصيف. \nالأهمية: يمثل هذا المهرجان عودة مالكا هابيل زيوا إلى عالم النور بعد فوزه في الحرب ضد عالم الظلام. \nالأنشطة: يتضمن الاحتفال طقوسًا مماثلة لتلك الخاصة بـ Parwanaya، مع التركيز على التجديد والتطهير. كما تشكل التجمعات والأعياد المجتمعية جزءًا أساسيًا من الاحتفالات.',
        '\nDehwa d-Šitil (مهرجان سيتيل) \nمتى: يُحتفل به في أواخر الصيف أو أوائل الخريف. \nالأهمية: يكرم هذا المهرجان شخصية شيتيل (سيث)، الذي يُعتبر كائنًا إلهيًا وشخصية منقذة في المعتقد المندائي. \nالأنشطة: يتضمن طقوس التطهير والتعميد والصلاة والوجبات الجماعية. كما أنه وقت لتذكر الموتى وتقديم القرابين على شرفهم.',
        '\nDehwa d-Edya (مهرجان رأس السنة) \nمتى: يُحتفل به عادةً في أوائل يناير. \nالأهمية: يمثل هذا المهرجان وصول النور إلى العالم. \nالأنشطة: يتضمن طقوس التطهير والصلاة الخاصة والولائم. إنه وقت الفرح والتجديد، حيث يجتمع المجتمع للاحتفال بالبداية الجديدة.',
        '\nقنا (أحد الذكرى) \nمتى: يتم الاحتفال به في الأحد الأول بعد الباروانايا. \nالأهمية: هذا اليوم مخصص لذكرى المتوفى وتبجيل الأسلاف. \nالأنشطة: تشمل الطقوس الصلوات والقرابين والمعموديات التي تُجرى تكريمًا للأرواح الراحلة.',
        '\nديهوا دايمانا (عيد) \nمتى: يتم الاحتفال به عادةً في منتصف شهر مايو. \nالأهمية: مهرجان يحتفل بعيد ميلاد يوحنا المعمدان، أعظم نبي مندائي وآخر نبي. يتم تعميد الأطفال لأول مرة خلال هذا المهرجان.',
        ],
      'image': 'assets/images/festival.jpeg',
    },
    {
      'title': 'Scriptures',
      'title_ar': 'الكتب المقدسة',
      'paragraphs': [
        'Ginza Rba (The Great Treasure) \nContent: The Ginza Rba is the most important and comprehensive of the Mandaean scriptures. It is divided into two main parts: the Right Ginza and the Left Ginza. The Right Ginza contains cosmological and theological texts, hymns, and prayers, while the Left Ginza deals with eschatological themes, such as the fate of the soul after death. \nThemes: Creation, cosmology, theology, ethics, and eschatology. \nSignificance: This text is considered the primary religious authority and is used in various rituals and ceremonies.',
        'Qolasta \nContent: The Qolasta is a collection of hymns, prayers, and liturgical texts used in Mandaean rituals, particularly those involving baptism (masbuta) and other purification rites. \nThemes: Worship, purification, and spiritual invocation. \nSignificance: The Qolasta is crucial for daily religious practices and is recited during major ceremonies and festivals.',
        'Sidra d-Yahia (The Book of John the Baptist) \nContent: This text contains teachings attributed to John the Baptist (Yahya), a central figure in Mandaean religion, as well as narratives about his life and mission. \nThemes: Ethical teachings, guidance for righteous living, and the role of John the Baptist. \nSignificance: It provides moral and ethical instructions and reinforces the importance of John the Baptist in Mandaean faith.',
        'Diwan Abatur \nContent: The Diwan Abatur is focused on the figure of Abatur, a key angelic being in Mandaean cosmology who judges the souls of the deceased. It describes the journey of the soul after death and the various stages it passes through. \nThemes: Afterlife, judgment, and the soul\'s journey. \nSignificance: It is used in funerary rites and helps Mandaeans understand the afterlife and the importance of living a righteous life.',
        'Haran Gawaita \nContent: This text provides a historical account of the Mandaeans, including their origins and migrations. It includes details about their persecution and the preservation of their religious identity. \nThemes: History, identity, and resilience. \nSignificance: It serves as a historical record and reinforces the community\'s sense of identity and continuity.',
        'Alma Rišaia Rba \nContent: Also known as "The Great First World," this text deals with the creation of the world and the heavenly realms. It describes the structure of the universe and the roles of various divine beings. \nThemes: Creation, cosmology, and divine hierarchy. \nSignificance: It provides a detailed account of Mandaean cosmology and the origins of the universe.',
        'Draša d-Iahia (The Teaching of John) \nContent: Similar to the Sidra d-Yahia, this text contains teachings and discourses attributed to John the Baptist, focusing on spiritual and ethical instructions. \nThemes: Spiritual guidance, ethical conduct, and the teachings of John the Baptist. \nSignificance: It offers practical advice for leading a righteous life and emphasizes the importance of spiritual purity.',
      ],
      'paragraphs_ar': [
        'كنزة ربا (الكنز الأعظم) \nالمحتوى: كنزة ربا هي أهم وأشمل الكتب المقدسة المندائية. وهي مقسمة إلى قسمين رئيسيين: كنزة يمينية وكنزة يسارية. تحتوي كنزة يمينية على نصوص كونية ولاهوتية وترانيم وصلوات، بينما تتناول كنزة يسارية موضوعات إسخاتولوجية، مثل مصير الروح بعد الموت. \nالموضوعات: الخلق، وعلم الكونيات، واللاهوت، والأخلاق، وعلم الإسخاتولوجيا. \nالأهمية: يعتبر هذا النص المرجع الديني الأساسي ويُستخدم في طقوس واحتفالات مختلفة.',
        'القلطة \nالمحتوى: القلطة هي مجموعة من الترانيم والصلوات والنصوص الطقسية المستخدمة في الطقوس المندائية، وخاصة تلك التي تنطوي على المعمودية (المصبوبة) وغيرها من طقوس التطهير. \nالموضوعات: العبادة والتطهير والدعاء الروحي. \nالأهمية: القلطة ضرورية للممارسات الدينية اليومية ويتم تلاوتها خلال الاحتفالات والمهرجانات الكبرى.',
        'سدرة يحيى (كتاب يوحنا المعمدان) \nالمحتوى: يحتوي هذا النص على تعاليم منسوبة إلى يوحنا المعمدان (يحيى)، وهو شخصية محورية في الديانة المندائية، بالإضافة إلى روايات عن حياته ورسالته. \nالموضوعات: التعاليم الأخلاقية، والتوجيه من أجل الحياة الصالحة، ودور يوحنا المعمدان. \nالأهمية: يقدم تعليمات أخلاقية ويعزز أهمية يوحنا المعمدان في العقيدة المندائية.',
        'ديوان الأباتور \nالمحتوى: يركز ديوان الأباتور على شخصية الأباتور، وهو كائن ملائكي رئيسي في علم الكونيات المندائي الذي يحكم على أرواح المتوفى. ويصف رحلة الروح بعد الموت والمراحل المختلفة التي تمر بها. \nالموضوعات: الحياة الآخرة، والحكم، ورحلة الروح. \nالأهمية: يستخدم في طقوس الجنازة ويساعد المندائيين على فهم الحياة الآخرة وأهمية عيش حياة صالحة.',
        'حَرْن كَوَيْتَا \nالمحتوى: يقدم هذا النص سردًا تاريخيًا للمندائيين، بما في ذلك أصولهم وهجراتهم. ويتضمن تفاصيل حول اضطهادهم والحفاظ على هويتهم الدينية. \nالموضوعات: التاريخ والهوية والمرونة. \nالأهمية: يعمل كسجل تاريخي ويعزز شعور المجتمع بالهوية والاستمرارية.',
        'ألما ريشايا ربا" المحتوى: يُعرف هذا النص أيضًا باسم "العالم الأول العظيم"، ويتناول خلق العالم والعوالم السماوية. ويصف بنية الكون وأدوار الكائنات الإلهية المختلفة. الموضوعات: الخلق وعلم الكون والتسلسل الإلهي. الأهمية: يقدم وصفًا تفصيليًا لعلم الكونيات المندائي وأصول الكون.',
        'دراسا د-يحيى (تعاليم يوحنا) \nالمحتوى: على غرار سدرة د-يحيى، يحتوي هذا النص على تعاليم وخطابات منسوبة إلى يوحنا المعمدان، مع التركيز على التعليمات الروحية والأخلاقية. \nالموضوعات: التوجيه الروحي، والسلوك الأخلاقي، وتعاليم يوحنا المعمدان. \nالأهمية: يقدم نصائح عملية لقيادة حياة صالحة ويؤكد على أهمية الطهارة الروحية.',
        ],
      'image': 'assets/images/texts.jpeg',
    },
  ];

  List<Map<String, String>> resourceItems = [
    {
      'title': 'Wikipedia',
      'title_ar': 'ويكيبيديا',
      'link': 'https://en.wikipedia.org/wiki/Mandaeans',
      'description': 'Official Mandaean Wikipedia',
      'description_ar': 'ويكيبيديا المندائية الرسمية',
    },
    {
      'title': 'Mandaean Podcast',
      'title_ar': 'بودكاست المندائيين',
      'link': 'https://www.youtube.com/@WeTheMandaeans',
      'description': 'Official Podcast For Mandaeans',
      'description_ar': 'البودكاست الرسمي للمندائيين',
    },
    {
      'title': 'Nasorean Instagram',
      'title_ar': 'انستغرام نصوري',
      'link': 'https://www.instagram.com/nasoraean/',
      'description': 'Informational Instagram For Mandaeans',
      'description_ar': 'انستغرام معلوماتي للمندائيين'
    },
    {
      'title': 'I-Am-Mandaean Instagram',
      'title_ar': 'انستغرام انا مندائي',
      'link': 'https://www.instagram.com/iam.mandean/',
      'description': 'Further Information About Mandaeans',
      'description_ar': 'معلومات إضافية عن المندائيين',
    },
    {
      'title': 'The Mandaean Association Facebook',
      'title_ar': 'جمعية المندائيين فيسبوك',
      'link': 'https://www.facebook.com/SabianMandaeanAssociation',
      'description': 'The Official Mandaean Facebook',
      'description_ar': 'الرابطة المندائية الرسمية على الفيسبوك',
    }
  ];

  final List<IconData> resourceIcons = [
    Icons.web,
    Icons.podcasts,
    Icons.camera_alt,
    Icons.camera_alt,
    Icons.group
  ];

  @override
  void initState() {
    super.initState();

    // Load the daily verse when the app starts
    loadRandomVerse();

    // Observe the language change and reload the verse accordingly.
    ever(profileController.isEnglish, (bool isEnglish) {
      loadRandomVerse();
    });
  }
  Future<void> loadRandomVerse() async {
    final isEnglish = profileController.isEnglish.value;

    if (isEnglish) {
      // Instead of loading the verse, display the "Coming Soon" message
      setState(() {
        dailyVerse = {
          'book': '',
          'chapter': '',
          'verse': '',
          'text': 'The English Ginza Is Coming Soon, Sorry For The Inconvenience',
        };
      });
    } else {
      // Load Arabic version
      String data = await rootBundle.loadString('assets/ginzas/ginzaArabic.json');
      Map<String, dynamic> jsonData = json.decode(data); // Parsing the root as a map

      // Extract the list of books from the JSON structure
      List<dynamic> books = jsonData['books']; // Assuming 'books' is the key for book list

      final random = Random();

      // Select a random book
      int randomBookIndex = random.nextInt(books.length);
      var book = books[randomBookIndex];

      // Select a random chapter from the selected book
      List<dynamic> chapters = book['chapters'];
      int randomChapterIndex = random.nextInt(chapters.length);
      var chapter = chapters[randomChapterIndex];

      // Select a random verse from the selected chapter
      List<dynamic> verses = chapter['verses'];
      int randomVerseIndex = random.nextInt(verses.length);
      var verse = verses[randomVerseIndex];

      setState(() {
        dailyVerse = {
          'book': book['book_name'],
          'chapter': chapter['chapter_number'],
          'verse': verse['verse_number'].toString(),
          'text': verse['text'],
        };
      });
    }
  }
  void copyToClipboard() {
    if (dailyVerse != null) {
      final quote = '${dailyVerse!['text']} - ${dailyVerse!['book']} ${dailyVerse!['chapter']}:${dailyVerse!['verse']}';
      Clipboard.setData(ClipboardData(text: quote));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard!')),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isEnglish = profileController.isEnglish.value;
    final title = isEnglish ? 'Daily Botha (verse)' : 'الآية اليومية';
    final resourceTitle = isEnglish ? 'Resources' : 'الموارد';
    final infoTitle = isEnglish ? 'Information' : 'معلومات';

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the title
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'GinzApp',
                    style: TextStyle(color: Colors.black), // Ensure text color matches your design
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: loadRandomVerse,
            ),
            IconButton(
              icon: const Icon(Icons.attach_money, color: Colors.amber),
              onPressed: () => _launchURL(donationUrl),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (dailyVerse != null)
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dailyVerse!['text']!,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '- ${dailyVerse!['book']} ${dailyVerse!['chapter']}:${dailyVerse!['verse']}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: copyToClipboard,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Quote'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 20),
              Text(
                infoTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 225,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: informationalItems.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 500),
                              pageBuilder: (context, animation, secondaryAnimation) {
                                // Retrieve the current language setting
                                // Retrieve the item data
                                final item = informationalItems[index];

                                // Determine the title and paragraphs based on the current language
                                final title = isEnglish ? item['title']! : item['title_ar']!;
                                final paragraphs = isEnglish
                                    ? List<String>.from(item['paragraphs'])
                                    : List<String>.from(item['paragraphs_ar']);

                                return InfoDetailScreen(
                                  title: title,
                                  paragraphs: paragraphs,
                                  image: item['image']!,
                                );
                              },
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.ease;

                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            )
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SizedBox(
                          width: 250,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.asset(
                                  informationalItems[index]['image']!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.black.withOpacity(0.3),
                                  colorBlendMode: BlendMode.darken,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEnglish
                                          ? informationalItems[index]['title']!
                                          : informationalItems[index]['title_ar']!,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      (isEnglish
                                          ? List<String>.from(informationalItems[index]['paragraphs']).first
                                          : List<String>.from(informationalItems[index]['paragraphs_ar']).first),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                resourceTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: resourceItems.length,
                itemBuilder: (context, index) {
                  final resourceTitle = isEnglish
                      ? resourceItems[index]['title']!
                      : resourceItems[index]['title_ar']!; // Assume 'title_ar' exists
                  final resourceDescription = isEnglish
                      ? resourceItems[index]['description']!
                      : resourceItems[index]['description_ar']!; // Assume 'description_ar' exists

                  return Card(
                    color: Colors.white, // Set background color to white
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Adjust radius for a modern look
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(resourceIcons[index], color: Colors.amber),
                      title: Text(resourceTitle),
                      subtitle: Text(resourceDescription),
                      onTap: () => _launchURL(resourceItems[index]['link']!),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}