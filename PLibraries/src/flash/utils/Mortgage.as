package flash.utils
{
	
	/**
	 *	房贷计算，等额本息法/等额本金法。
	 * 	<p>等额本息法:（每个月的还款额相等）月还款额=本金*月利率*[(1+月利率)^n/[(1+月利率)^n-1] 式中n表示贷款月数，^n表示n次方，如^180，表示180次方（贷款15年）</p>
	 * 	<p>等额本金法：（第一个月还款额最多，以后逐月递减）月还款额=本金/n+剩余本金*月利率  n表示贷款月数</p>
	 * 
	 *	@author Huangmin
	 *	@date	2013-6-29
	 */
	public class Mortgage
	{
		
		/**
		 * 	房贷计算<u>等额本息法</u>，<b>按贷款总额度计算</b>。
		 * 	<p>等额本息法:（每个月的还款额相等）月还款额=本金*月利率*[(1+月利率)^n/[(1+月利率)^n-1] 式中n表示贷款月数，^n表示n次方，如^180，表示180次方（贷款15年）</p>
		 * 
		 * 	@param amount:Number		付款总额，单位：万元
		 * 	@param deadline:Number	贷款期限，单位：年
		 * 	@param air:Number		年  利  率，单位：百分比；例6.55%,输入6.55
		 * 
		 * 	@return 一个计算结果对象<code>Object</code>类型，对象属性包括:
		 * 	<li>housingFund:Number 		房款总额，单位：元</li>
		 * 	<li>loanAmount:Number 		贷款总额，单位：元</li>
		 * 	<li>repaymentAmount:Number 	还款总额，单位：元</li>
		 * 	<li>paymentInterest:Number 	支付利息，单位：元</li>
		 * 	<li>firstPayment:Number 	首期付款，单位：元</li>
		 * 	<li>loansMonths:Number 		贷款月数</li>
		 * 	<li>meanMonths:Number 		月均还款，单位：元</li>	
		 * 	<li>airMonths:Number		月利率</li>
		 */
		public static function averageInterestForAmountCalc(amount:Number, deadline:Number, air:Number = 6.55):Object
		{
			var result:Object = new Object();
			//贷款总额单位：元
			result.loanAmount = amount * 10000;
			//贷款总月数
			result.loansMonths = deadline * 12;
			//转换为单位：月利率
			result.airMonths = air * 0.01 / 12;
			//房款总额
			result.housingFund = null;
			//月均还款额	  =  本金(贷款总额数)  * 月利率  *  [(1+月利率)^n / [(1+月利率)^n - 1] 式中n表示贷款月数，^n表示n次方
			result.meanMonths = result.loanAmount * result.airMonths * (Math.pow((1 + result.airMonths), result.loansMonths) / (Math.pow((1 + result.airMonths), result.loansMonths) - 1));
			//还款总额数	 = 月均还款额  * 贷款总月数
			result.repaymentAmount = result.meanMonths * result.loansMonths;
			//支付利息总额    =  还款总额数	 - 房款总额
			result.paymentInterest = result.repaymentAmount - result.loanAmount;
			//首期付款
			result.firstPayment = 0;
			
			return result;
		}
		
		
		/**
		 *	 房贷计算<u>等额本息法</u>，<b>按购买面积计算</b>。
		 * 	<p>等额本息法:（每个月的还款额相等）月还款额=本金*月利率*[(1+月利率)^n/[(1+月利率)^n-1] 式中n表示贷款月数，^n表示n次方，如^180，表示180次方（贷款15年）</p>
		 * 
		 * 	@param unitPrice:Number			单价面积，单位：元/平方米
		 * 	@param area:Number				购买面积，单位：平方米
		 * 	@param mortgagePercent:Number	按揭成数，单位：百分比；按揭8成,输入80
		 * 	@param deadline:Number			按揭年数，单位：年
		 * 	@param air:Number				年  利  率，单位：百分比；例6.55%,输入6.55
		 * 
		 *  @return 一个计算结果对象<code>Object</code>类型，对象属性包括:
		 * 	<li>housingFund:Number 		房款总额，单位：元</li>
		 * 	<li>loanAmount:Number 		贷款总额，单位：元</li>
		 * 	<li>repaymentAmount:Number 	还款总额，单位：元</li>
		 * 	<li>paymentInterest:Number 	支付利息，单位：元</li>
		 * 	<li>firstPayment:Number 	首期付款，单位：元</li>
		 * 	<li>remainderPayment:Number	剩余付款，单位：元</li>
		 * 	<li>loansMonths:Number 		贷款月数</li>
		 * 	<li>meanMonths:Number 		月均还款，单位：元</li>
		 * 	<li>airMonths:Number		月利率</li>
		 */
		public static function averageInterestForAreaCalc(unitPrice:Number, area:Number, mortgagePercent:Number, deadline:Number, air:Number = 6.55):Object
		{
			//房款总额	单位：元
			var housingFund:Number = unitPrice * area;
			//首期支付	单位：元
			var firstPayment:Number = housingFund * (1 - mortgagePercent * 0.01);
			//剩余付款总额	单位：元
			var remainderPayment:Number = housingFund * mortgagePercent * 0.01;
			
			var result:Object = averageInterestForAmountCalc(remainderPayment / 10000, deadline, air);
			result.housingFund = housingFund;
			result.firstPayment = firstPayment;
			result.remainderPayment = remainderPayment;
			
			return result;
		}
		
		
		/**
		 *	 房贷计算<u>等额本息法</u>，<b>组合计算，公积金+商业贷款</b>。
		 * 
		 * 	@param deadline:Number		按揭年数，单位：年
		 * 	@param pLoanAmount:Number	公积金贷款金额，单位：万元
		 * 	@param pAir:Number			公积金贷款利率，单位：百分比
		 * 	@param bLoanAmount:Number	商业贷款金额，单位：万元
		 * 	@param bAir:Number			商业贷款利率，单位：百分比
		 * 
		 * 	@return 一个计算结果对象<code>Object</code>类型，对象属性包括:
		 * 	<li>housingFund:Number 		房款总额，单位：元</li>
		 * 	<li>loanAmount:Number 		贷款总额，单位：元</li>
		 * 	<li>repaymentAmount:Number 	还款总额，单位：元</li>
		 * 	<li>paymentInterest:Number 	支付利息，单位：元</li>
		 * 	<li>firstPayment:Number 	首期付款，单位：元</li>
		 * 	<li>loansMonths:Number 		贷款月数</li>
		 * 	<li>meanMonths:Number 		月均还款，单位：元</li>
		 */
		public static function averageInterestForComponentCalc(deadline:Number, pLoanAmount:Number, pAir:Number, bLoanAmount:Number, bAir:Number):Object
		{
			var pResult:Object = averageInterestForAmountCalc(pLoanAmount, deadline, pAir);
			var bResult:Object = averageInterestForAmountCalc(bLoanAmount, deadline, bAir);
			
			var result:Object = new Object();
			//房款总额
			result.housingFund = null;
			//贷款总额单位：元
			result.loanAmount = pResult.loanAmount + bResult.loanAmount;
			//贷款总月数
			result.loansMonths = pResult.loansMonths;
			//支付利息总额 
			result.paymentInterest = pResult.paymentInterest + bResult.paymentInterest;
			//平均月利率
			//result.airMonths = (pResult.airMonths + bResult.airMonths) / 2;
			//月均还款额	 
			result.meanMonths = pResult.meanMonths + bResult.meanMonths;
			//还款总额数	
			result.repaymentAmount = pResult.repaymentAmount + bResult.repaymentAmount
			//首期付款
			result.firstPayment = 0;
			
			return result;
		}
		
		/**
		 * 	房贷计算<u>等额本金法</u>，<b>按贷款总额度计算</b>。
		 * 	<p>等额本金法：（第一个月还款额最多，以后逐月递减）月还款额=本金/n+剩余本金*月利率  n表示贷款月数</p>
		 * 
		 * 	@param amount:Number		付款总额，单位：万元
		 * 	@param deadline:Number	贷款期限，单位：年
		 * 	@param air:Number		年  利  率，单位：百分比；例6.55%,输入6.55
		 * 
		 * 	@return 一个计算结果对象<code>Object</code>类型，对象属性包括:
		 * 	<li>loanAmount:Number 				贷款总额，单位：元</li>
		 * 	<li>repaymentAmount:Number 			还款总额，单位：元</li>
		 * 	<li>paymentInterest:Number 			支付利息总额，单位：元</li>
		 * 	<li>meanAir:Vector.&lt;Number&gt;		每月支付利息，单位元</li>
		 * 	<li>firstPayment:Number 			首期付款，单位：元</li>
		 * 	<li>loansMonths:Number 				贷款月数</li>
		 * 	<li>meanRepayment:Number 			月均还款，单位：元</li>
		 * 	<li>meanMonths:Vector.&lt;Number&gt;	每月应还款额，单位：元</li>
		 * 	<li>airMonths:Number				月利率</li>
		 */
		public static function averageCapitalForAmountCalc(amount:Number, deadline:Number, air:Number = 6.55):Object
		{
			var result:Object = new Object();
			//贷款总额单位：元
			result.loanAmount = amount * 10000;
			//贷款总月数
			result.loansMonths = int(deadline * 12);
			//转换为单位：月利率
			result.airMonths = air * 0.01 / 12;
			//房款总额
			result.housingFund = null;
			//月均还款额	  =  本金(贷款总额数) / 贷款总月数		***注意是月均还款额
			result.meanRepayment = result.loanAmount / result.loansMonths;
			//每月还款利息	=  (贷款本金 - 已归还本金累计额 ) × 季利率
			result.meanAir = new Vector.<Number>(result.loansMonths, true);
			//每月还款客		= 	月均还款额   + 每月还款利息
			result.meanMonths = new Vector.<Number>(result.loansMonths, true);
			//支付利息总额    =  累计每月支付利息
			result.paymentInterest = 0;
					
			for(var i:int = 0; i < result.loansMonths; i ++)
			{
				//每月还款利息
				var meanAir:Number = (result.loanAmount - result.meanRepayment * i) * result.airMonths;
				//每月还款额
				var meanMonths:Number = result.meanRepayment + meanAir;
				
				result.paymentInterest += meanAir;				
				result.meanAir[i] = meanAir;
				result.meanMonths[i] = meanMonths;
			}
			
			//还款总额数	 = 贷款总额 + 支付利息总额 
			result.repaymentAmount = result.loanAmount + result.paymentInterest;
			//首期付款
			result.firstPayment = 0;
			
			return result;
		}
		
		/**
		 *	 房贷计算<u>等额本金法</u>，<b>按购买面积计算</b>。
		 * 	<p>等额本金法：（第一个月还款额最多，以后逐月递减）月还款额=本金/n+剩余本金*月利率  n表示贷款月数</p>
		 * 
		 * 	@param unitPrice:Number			单价面积，单位：元/平方米
		 * 	@param area:Number				购买面积，单位：平方米
		 * 	@param mortgagePercent:Number	按揭成数，单位：百分比；例首会支付20%,输入20
		 * 	@param deadline:Number			按揭年数，单位：年
		 * 	@param air:Number				年  利  率，单位：百分比；例6.55%,输入6.55
		 * 
		 *	@return 一个计算结果对象<code>Object</code>类型，对象属性包括:
		 * 	<li>housingFund:Number 				房款总额，单位：元</li>
		 * 	<li>loanAmount:Number 				贷款总额，单位：元</li>
		 * 	<li>repaymentAmount:Number 			还款总额，单位：元</li>
		 * 	<li>paymentInterest:Number 			支付利息总额，单位：元</li>
		 * 	<li>meanAir:Vector.&lt;Number&gt;		每月支付利息，单位元</li>
		 * 	<li>firstPayment:Number 			首期付款，单位：元</li>
		 * 	<li>loansMonths:Number 				贷款月数</li>
		 * 	<li>meanRepayment:Number 			月均还款，单位：元</li>
		 * 	<li>meanMonths:Vector.&lt;Number&gt;	每月应还款额，单位：元</li>
		 * 	<li>repaymentAmount:Number 			还款总额，单位：元</li>
		 * 	<li>airMonths:Number				月利率</li>
		 */
		public static function averageCapitalForAreaCalc(unitPrice:Number, area:Number, mortgagePercent:Number, deadline:Number, air:Number = 6.55):Object
		{
			//房款总额	单位：元
			var housingFund:Number = unitPrice * area;
			//首期支付	单位：元
			var firstPayment:Number = housingFund * (1 - mortgagePercent * 0.01);
			//剩余付款总额	单位：元
			var remainderPayment:Number = housingFund * mortgagePercent * 0.01;
			
			var result:Object = averageCapitalForAmountCalc(remainderPayment / 10000, deadline, air);
			result.housingFund = housingFund;
			result.firstPayment = firstPayment;
			result.remainderPayment = remainderPayment;
			
			return result;
		}
		
		
		/**
		 *	 房贷计算<u>等额本金法</u>，<b>组合计算，公积金+商业贷款</b>。
		 * 
		 * 	@param deadline:Number		按揭年数，单位：年
		 * 	@param pLoanAmount:Number	公积金贷款金额，单位：万元
		 * 	@param pAir:Number			公积金贷款利率，单位：百分比
		 * 	@param bLoanAmount:Number	商业贷款金额，单位：万元
		 * 	@param bAir:Number			商业贷款利率，单位：百分比
		 * 
		 * 	@return 一个计算结果对象<code>Object</code>类型，对象属性包括:
		 * 	<li>loanAmount:Number 				贷款总额，单位：元</li>
		 * 	<li>repaymentAmount:Number 			还款总额，单位：元</li>
		 * 	<li>paymentInterest:Number 			支付利息总额，单位：元</li>
		 * 	<li>meanAir:Vector.&lt;Number&gt;		每月支付利息，单位元</li>
		 * 	<li>firstPayment:Number 			首期付款，单位：元</li>
		 * 	<li>loansMonths:Number 				贷款月数</li>
		 * 	<li>meanRepayment:Number 			月均还款，单位：元</li>
		 * 	<li>meanMonths:Vector.&lt;Number&gt;	每月应还款额，单位：元</li>
		 */
		public static function averageCapitalForComponentCalc(deadline:Number, pLoanAmount:Number, pAir:Number, bLoanAmount:Number, bAir:Number):Object
		{
			var pResult:Object = averageCapitalForAmountCalc(pLoanAmount, deadline, pAir);
			var bResult:Object = averageCapitalForAmountCalc(bLoanAmount, deadline, bAir);
			
			var result:Object = new Object();
			//贷款总额
			result.loanAmount = pResult.loanAmount + bResult.loanAmount;
			//还款总额
			result.repaymentAmount = pResult.repaymentAmount + bResult.repaymentAmount;
			//支付利息总额
			result.paymentInterest = pResult.paymentInterest + bResult.paymentInterest;
			//首期付款
			result.firstPayment = 0;
			//贷款总月数
			result.loansMonths = pResult.loansMonths;
			//月均还款
			result.meanRepayment = pResult.meanRepayment + bResult.meanRepayment;
			
			
			//每月支付利息
			result.meanAir = new Vector.<Number>(result.loansMonths, true);
			//每月应还款额
			result.meanMonths = new Vector.<Number>(result.loansMonths, true); 
			
			for(var i:int = 0; i < result.loansMonths; i ++)
			{
				result.meanAir[i] = Number(pResult.meanAir[i]) + Number(bResult.meanAir[i]);
				result.meanMonths[i] = Number(pResult.meanMonths[i]) + Number(bResult.meanMonths[i]);
			}
			
			return result;
		}
	}
}
