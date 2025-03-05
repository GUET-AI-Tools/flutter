class Global {
  static final List<String> foodTypes = ['谷物', '蔬菜', '水果', '豆类', '坚果', '肉类', '蛋类', '乳制品', '油脂', '糖类', '罐头'];

  static String username = 'default';

  static final doubaoModelId = 'ep-20250219134730-wbfm4';
  static final dsModelId = 'bot-20250219170805-k4j4q';

  static final doubaoPrompt = '你需要将输入的图片中的食材以json格式输出，不需要附带其他内容，'
      '需要在json中列出物品的名字与数量并按 谷物、蔬菜、水果、豆类、坚果、肉类、蛋类、乳制品、油脂、糖类、罐头 进行分类。'
      '每个分类对应一个数组，数组中存放对应的所有食材的名字与数量，食材与数量应当以键值对的形式输出，若分类中不存在对应的食材也要输出对应的数组。'
      '忽略物品的颜色与大小，名字仅输出其常用名称，数量不需要量词。';

  static final dsPrompt = '你的任务是解析收到的json文本中的食材，并给出合适的食谱，不要求使用所有食材。'
      '对于可数的食材，其数字代表其完整的个数。以下是json文本：<json_text>{{JSON_TEXT}}</json_text>请按照以下步骤完成任务：'
      '1. 仔细解析json文本，提取其中的食材信息。2. 根据提取的食材，思考合适的食谱，不要求使用所有食材。'
      '3. 依照输入的json格式输出所消耗的食材，即使是未使用的食材种类也要列出。'
      '4. 食谱使用markdown格式详细列出所需要的食材、调料与烹饪步骤。请在<used_ingredients>标签内输出所消耗的食材，在<recipe>标签内输出食谱。';

  static final doubaoApiKey = '908ff8ed-3064-4be1-bec3-43dd8afe3760';
  static final dsApiKey = 'dc97c090-11a9-43cc-b09a-a0466ed56e69';

  static final doubaoBaseUrl = 'https://ark.cn-beijing.volces.com/api/v3';
  static final dsBaseUrl = 'https://ark.cn-beijing.volces.com/api/v3/bots';
}